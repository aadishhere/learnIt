//
//  ContentView.swift
//  learnIt
//
//  Created by Aadish Jain on 27/01/25.
//

import SwiftUI

struct ContentView: View {
    @State private var topic: String = ""
    @State private var isProcessing: Bool = false
    @State private var summary: String = ""
    @State private var quiz: [String] = []
    @State private var predictedQuestions: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Title
                Text("LearnIt")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                // Topic Input
                TextField("Enter a topic...", text: $topic)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Submit Button
                Button(action: {
                    isProcessing = true
                    processTopic()
                }) {
                    Text(isProcessing ? "Processing..." : "Generate")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isProcessing ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isProcessing || topic.isEmpty)

                // Output Sections
                ScrollView {
                    if !summary.isEmpty {
                        Section(header: Text("Summary").font(.headline).padding(.top)) {
                            Text(summary)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }

                    if !quiz.isEmpty {
                        Section(header: Text("Quiz").font(.headline).padding(.top)) {
                            ForEach(quiz, id: \..self) { question in
                                Text("- \(question)")
                                    .padding(.vertical, 5)
                            }
                        }
                    }

                    if !predictedQuestions.isEmpty {
                        Section(header: Text("Predicted Questions").font(.headline).padding(.top)) {
                            ForEach(predictedQuestions, id: \..self) { question in
                                Text("- \(question)")
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }

    func processTopic() {
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Example output
            summary = "This is a concise summary of the topic \(topic)."
            quiz = ["What is \(topic)?", "Explain the basics of \(topic).", "Why is \(topic) important?"]
            predictedQuestions = ["How does \(topic) work?", "What are common applications of \(topic)?"]

            isProcessing = false
        }
    }
}

struct LearnItApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
