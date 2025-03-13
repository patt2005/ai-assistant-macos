//
//  OpenAiApi.swift
//  AiAssistant
//
//  Created by Petru Grigor on 04.03.2025.
//

import Foundation

class OpenAiApi {
    static let shared = OpenAiApi()
    
    private init() {}
    
    private struct ChatMessageApiResponse: Decodable {
        struct Choice: Decodable {
            let delta: Delta
        }
        
        struct Delta: Decodable {
            let content: String
        }
        
        let choices: [Choice]
    }
    
    private struct ApiResponse: Decodable {
        let claudeAiApiKey: String
        let openAiApiKey: String
        let qwenApiKey: String
    }
    
    func getChatResponse(prompt: String) async throws -> AsyncThrowingStream<String, Error> {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Constants.shared.openAiApiKey)"
        ]
        
        let messages: [[String: Any]] = [
            [
                "role": "developer",
                "content": "You are an intelligent personal AI assistant running on macOS. Your goal is to help users with their daily tasks, provide accurate answers, and assist with coding, productivity, and general inquiries. You should be concise, helpful, and always maintain a friendly and professional tone. If a request involves actions outside your capabilities, politely inform the user."
            ],
            [
                "role": "user",
                "content": prompt
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "max_tokens": 1024,
            "messages": messages,
            "stop": [
                "\n\n\n",
                "<|im_end|>"
            ],
            "stream": true,
        ]
        
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpMethod = "POST"
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw JsonError.invalidData
        }
        request.httpBody = jsonData
        
        let (result, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Error: Invalid Http Response")
            throw ChatMessageError.invalidData
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            print("Error: Invalid Http Response: \(httpResponse.statusCode)")
            throw ChatMessageError.invalidHttpResponse
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in result.lines {
                        if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8), let response = try? JSONDecoder().decode(ChatMessageApiResponse.self, from: data), let text = response.choices.first?.delta.content {
                            continuation.yield(text)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
