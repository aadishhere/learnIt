import SwiftUI

struct HomeView: View {
    // MARK: - States
    @State private var inputText: String = ""
    @State private var response: OpenAIResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Quiz-related states
    @State private var selectedAnswers: [Int: String] = [:]
    @State private var score = 0
    @State private var shuffledOptions: [[String]] = []
    // Used for resetting the quiz view on retry.
    @State private var quizRetryID = UUID()
    
    let networkController = NetworkController.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Fixed white background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            // Main Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Logo
                    AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/fbffedcc81d354e47a5ce28ad12d75233a5a4a4d")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 300)
                                .padding(.bottom, 10)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 150)
                                .padding(.bottom, 10)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.top, 30)
                    
                    // Topic Input Controls
                    HStack(spacing: 15) {
                        // Custom placeholder with ZStack
                        ZStack(alignment: .leading) {
                            if inputText.isEmpty {
                                Text("Enter topic (e.g., Graphs)")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 20)
                            }
                            TextField("", text: $inputText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .foregroundColor(.black)
                                .submitLabel(.done)
                                .onSubmit { hideKeyboard() }
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        
                        Button(action: {
                            hideKeyboard()  // Dismiss keyboard on send.
                            fetchData()
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.orange)
                        }
                        .disabled(inputText.isEmpty)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                    .background(Color(white: 0.95))  // Grey bar behind input.
                    
                    // Loader or Error Message
                    if isLoading {
                        ProgressView("Generating...")
                            .padding()
                            .foregroundColor(.black)
                    } else if let error = errorMessage {
                        ErrorView(message: error)
                    }
                    
                    // Response Display Section
                    if let res = response {
                        VStack(alignment: .leading, spacing: 24) {
                            // Summary Section
                            Text("Summary")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            Text(res.summary)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(white: 0.9), lineWidth: 1)
                                )
                                .cornerRadius(10)
                                .padding(.horizontal)
                            
                            // Quiz Section
                            Text("Quiz")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            
                            // Use id to force a fresh instance on retry.
                            if currentQuizNotFinished(for: res) {
                                QuizCardStackImproved(questions: res.quizQuestions,
                                                      shuffledOptions: shuffledOptions,
                                                      selectedAnswers: $selectedAnswers,
                                                      score: $score)
                                .id(quizRetryID)
                                .padding(.horizontal)
                            }
                            
                            // Final score and Retry button
                            if selectedAnswers.count == res.quizQuestions.count {
                                VStack(spacing: 12) {
                                    Text("✅ You scored \(score) out of \(res.quizQuestions.count)")
                                        .font(.title3)
                                        .foregroundColor(.black)
                                        .padding(.horizontal)
                                    
                                    Button(action: {
                                        retryQuiz()
                                    }) {
                                        Text("Retry Quiz")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Predicted Questions Section
                            Text("Predicted Questions")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(res.predictedQuestions, id: \.self) { question in
                                    Text("• \(question)")
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
                .frame(maxWidth: 480)
                .padding(.bottom, 120)
            }
            .onTapGesture { hideKeyboard() }
            
            // Persistent Save Bookmark Button
            if let res = response {
                SaveButton(response: res)
                    .padding(.bottom, 20)
            }
        }
        .accentColor(.orange)
    }
    
    // Helper: returns true if there are unanswered quiz questions.
    func currentQuizNotFinished(for response: OpenAIResponse) -> Bool {
        return selectedAnswers.count < response.quizQuestions.count
    }
    
    // MARK: - Data Fetching
    func fetchData() {
        isLoading = true
        errorMessage = nil
        response = nil
        selectedAnswers = [:]
        score = 0
        shuffledOptions = []
        
        networkController.fetchLearningContent(for: inputText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let res):
                    self.response = res
                    // Shuffle options for each question.
                    self.shuffledOptions = res.quizQuestions.map {
                        ($0.wrongAnswers + [$0.correctAnswer]).shuffled()
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Retry Quiz
    func retryQuiz() {
        selectedAnswers = [:]
        score = 0
        quizRetryID = UUID()
    }
    
    // MARK: - Keyboard Dismiss Helper
#if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
#endif
}

// MARK: - Improved Quiz Card Stack

struct QuizCardStackImproved: View {
    let questions: [OpenAIResponse.QuizQuestion]
    let shuffledOptions: [[String]]
    @Binding var selectedAnswers: [Int: String]
    @Binding var score: Int
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                if index >= currentIndex {
                    QuestionCardImproved(
                        question: question,
                        options: shuffledOptions[index],
                        selectedAnswer: $selectedAnswers[index],
                        currentIndex: index,
                        totalQuestions: questions.count,
                        onAnswer: { isCorrect in
                            if isCorrect { score += 1 }
                            // Auto-transition if NOT the last question.
                            if index < questions.count - 1 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeInOut) {
                                        currentIndex += 1
                                    }
                                }
                            }
                        }
                    )
                    .offset(x: 0, y: CGFloat(index - currentIndex) * 10)
                    .transition(.move(edge: .top))
                    .zIndex(Double(questions.count - index))
                }
            }
        }
        .frame(height: 350)
    }
}

// MARK: - Improved Question Card View

struct QuestionCardImproved: View {
    let question: OpenAIResponse.QuizQuestion
    let options: [String]
    @Binding var selectedAnswer: String?
    let currentIndex: Int
    let totalQuestions: Int
    let onAnswer: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Question \(currentIndex + 1) of \(totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            Text(question.question)
                .font(.headline)
                .foregroundColor(.black)
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selectedAnswer == nil {
                        selectedAnswer = option
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onAnswer(option == question.correctAnswer)
                        }
                    }
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping.
                        Spacer()
                        if let selected = selectedAnswer {
                            if option == question.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if option == selected && option != question.correctAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedAnswer == option ?
                                  (option == question.correctAnswer ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                  : Color.white)
                    )
                }
                .disabled(selectedAnswer != nil)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        // Removed the shadow as requested.
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    var body: some View {
        Text("⚠️ \(message)")
            .foregroundColor(.red)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
    }
}

// MARK: - Save Button

struct SaveButton: View {
    let response: OpenAIResponse
    var body: some View {
        Button(action: {
            var saved = UserDefaults.standard.loadBookmarks()
            saved.append(response)
            UserDefaults.standard.saveBookmarks(saved)
        }) {
            Label("Save to Bookmarks", systemImage: "bookmark")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
}

// MARK: - UserDefaults Bookmark Helpers

extension UserDefaults {
    func saveBookmarks(_ items: [OpenAIResponse]) {
        if let data = try? JSONEncoder().encode(items) {
            set(data, forKey: "savedSummaries")
        }
    }
    
    func loadBookmarks() -> [OpenAIResponse] {
        guard let data = data(forKey: "savedSummaries") else { return [] }
        return (try? JSONDecoder().decode([OpenAIResponse].self, from: data)) ?? []
    }
}

// MARK: - Safe Subscript Extension

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
