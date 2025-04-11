import Foundation

struct OpenAIResponse: Identifiable, Codable {
    var id = UUID()
    let summary: String
    let quizQuestions: [QuizQuestion]
    let predictedQuestions: [String]
    
    struct QuizQuestion: Codable, Hashable {
        let question: String
        let correctAnswer: String
        let wrongAnswers: [String]
    }
    
    static func from(content: String) -> OpenAIResponse {
        let sections = content.components(separatedBy: "[SUMMARY]")
        guard sections.count > 1 else { return emptyResponse() }
        
        let summaryPart = sections[1].components(separatedBy: "[QUIZ]")
        let summary = summaryPart[0].trimmingCharacters(in: .whitespacesAndNewlines)
        
        let quizPredictedPart = summaryPart[1].components(separatedBy: "[PREDICTED]")
        let quizContent = quizPredictedPart[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let predictedContent = quizPredictedPart[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        return OpenAIResponse(
            summary: summary,
            quizQuestions: parseQuiz(content: quizContent),
            predictedQuestions: parsePredicted(content: predictedContent)
        )
    }
    
    private static func parseQuiz(content: String) -> [QuizQuestion] {
        let questionBlocks = content.components(separatedBy: "\n\n")
        return questionBlocks.compactMap { block in
            let lines = block.components(separatedBy: .newlines)
            guard lines.count >= 3,
                  let question = lines.first?.trimmingCharacters(in: .whitespaces),
                  question.rangeOfCharacter(from: .decimalDigits) != nil else { return nil }
            
            var correctAnswer = ""
            var wrongAnswers: [String] = []
            
            for line in lines {
                if line.lowercased().contains("correct answer:") {
                    correctAnswer = line.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? ""
                }
                else if line.lowercased().contains("wrong answers:") {
                    wrongAnswers = line.components(separatedBy: ":").last?
                        .components(separatedBy: "|")
                        .map { $0.trimmingCharacters(in: .whitespaces) } ?? []
                }
            }
            
            guard !correctAnswer.isEmpty, wrongAnswers.count >= 2 else { return nil }
            
            return QuizQuestion(
                question: question.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression),
                correctAnswer: correctAnswer,
                wrongAnswers: wrongAnswers
            )
        }
    }
    
    private static func parsePredicted(content: String) -> [String] {
        content.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { line in
                line.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
            }
    }
    
    private static func emptyResponse() -> OpenAIResponse {
        OpenAIResponse(
            summary: "No content available",
            quizQuestions: [],
            predictedQuestions: []
        )
    }
}
