import SwiftUI

struct BookmarksView: View {
    @State private var bookmarks: [OpenAIResponse] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarks) { bookmark in
                    NavigationLink(destination: BookmarkDetailView(bookmark: bookmark)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bookmark.summary)
                                .font(.subheadline)
                                .lineLimit(2)
                            Text("\(bookmark.quizQuestions.count) questions")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: deleteBookmarks)
            }
            .navigationTitle("Bookmarks")
            .toolbar {
                EditButton()
            }
            .onAppear(perform: loadBookmarks)
        }
    }
    
    private func loadBookmarks() {
        bookmarks = UserDefaults.standard.loadBookmarks()
    }
    
    private func deleteBookmarks(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
        UserDefaults.standard.saveBookmarks(bookmarks)
    }
}

struct BookmarkDetailView: View {
    let bookmark: OpenAIResponse
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: Summary Section
                Text("Summary")
                    .font(.headline)
                    .padding(.horizontal)
                Text(bookmark.summary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // MARK: Quiz Section
                Text("Quiz")
                    .font(.headline)
                    .padding(.horizontal)
                ForEach(Array(bookmark.quizQuestions.enumerated()), id: \.offset) { index, question in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Q\(index + 1): \(question.question)")
                            .fontWeight(.medium)
                        
                        // Build options using a shuffled combination for display.
                        let options = (question.wrongAnswers + [question.correctAnswer]).shuffled()
                        ForEach(options, id: \.self) { option in
                            HStack {
                                Text(option)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if option == question.correctAnswer {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(6)
                            .background(option == question.correctAnswer ? Color.green.opacity(0.3) : Color.orange.opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: Predicted Questions Section
                Text("Predicted Questions")
                    .font(.headline)
                    .padding(.horizontal)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bookmark.predictedQuestions, id: \.self) { predicted in
                        Text("• \(predicted)")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Bookmark Details")
    }
}
