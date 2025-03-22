//
//  OpenAiApi.swift
//  AiAssistant
//
//  Created by Petru Grigor on 04.03.2025.
//

import Foundation

class QwenAiApi {
    static let shared = QwenAiApi()
    
    var sessionId: String?
    
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
    
    private struct QwenAiApiResponse: Decodable {
        struct Output: Decodable {
            let session_id: String
            let text: String
        }
        
        let output: Output
    }
    
    func getApiResponse(prompt: String, imageUrl: String, screenResolution: NSSize) async throws -> ApiResponse {
        guard let url = URL(string: "https://dashscope-intl.aliyuncs.com/api/v1/apps/\(Constants.shared.applicationId)/completion") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Constants.shared.qwenAiApi)"
        ]
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let requestBody: [String: Any] = [
            "parameters": [:],
            "biz_params": [
                "ScreenWidth": screenResolution.width,
                "ScreenHeight": screenResolution.height
            ],
            "debug": [:],
            "input": sessionId != nil ? [
                "prompt": prompt,
                "session_id": sessionId
            ] : [
                "prompt": prompt
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw JsonError.invalidData
        }
        request.httpBody = jsonData
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let jsonDecoder = JSONDecoder()
        
        let decoded = try jsonDecoder.decode(QwenAiApiResponse.self, from: data)
        sessionId = decoded.output.session_id
        
        let jsonString = decoded.output.text.replacingOccurrences(of: "```json\n", with: "").replacingOccurrences(of: "\n```", with: "")
        guard let jsonData = jsonString.data(using: .utf8) else { throw JsonError.invalidData }
        
        return try jsonDecoder.decode(ApiResponse.self, from: jsonData)
    }
    
    func getChatResponse(prompt: String, imagesList: [String]) async throws -> AsyncThrowingStream<String, Error> {
        guard let url = URL(string: "https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Constants.shared.qwenAiApi)"
        ]
        
        var messages: [[String: Any]] = [
            [
                "role": "assistant",
                "content": [["type": "text", "text": "You are an intelligent personal AI assistant running on macOS. Your goal is to help users with their daily tasks, provide accurate answers, and assist with coding, productivity, and general inquiries. You should be concise, helpful, and always maintain a friendly and professional tone. If a request involves actions outside your capabilities, politely inform the user."]]
            ]
        ]
        
        var userMessageContent: [[String: Any]] = []
        
        imagesList.forEach { image in
            userMessageContent.insert(["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)"]], at: 0)
        }
        
        userMessageContent.append(["type": "text", "text": prompt])
        
        messages.append([
            "role": "user",
            "content": userMessageContent,
        ])
        
        let requestBody: [String: Any] = [
            "model": "qwen-vl-max",
            "messages": messages,
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
