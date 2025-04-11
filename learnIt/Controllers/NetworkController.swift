import Foundation

class NetworkController {
    static let shared = NetworkController()
    private let apiKey = "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"
    
    func fetchLearningContent(for topic: String, completion: @escaping (Result<OpenAIResponse, Error>) -> Void) {
        let endpoint = "https://api.openai.com/v1/chat/completions"
        
        let systemPrompt = """
        Format response EXACTLY like this:
        
        [SUMMARY]
        {Concise 200-word summary}
        
        [QUIZ]
        1. {Question 1}?
        Correct Answer: {Correct answer}
        Wrong Answers: {Wrong 1} | {Wrong 2} | {Wrong 3}
        
        2. {Question 2}?
        Correct Answer: {Correct answer}
        Wrong Answers: {Wrong 1} | {Wrong 2} | {Wrong 3}
        
        3. {Question 3}?
        Correct Answer: {Correct answer}
        Wrong Answers: {Wrong 1} | {Wrong 2} | {Wrong 3}
        
        [PREDICTED]
        1. {Predicted question 1}
        2. {Predicted question 2}
        3. {Predicted question 3}
        """
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": "Topic: \(topic)"]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
                guard let content = response.choices.first?.message.content else {
                    throw NSError(domain: "No content", code: -3)
                }
                
                let parsedResponse = OpenAIResponse.from(content: content)
                completion(.success(parsedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct OpenAIChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
