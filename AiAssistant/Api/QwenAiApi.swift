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
        
        var input: [String: Any] = [
            "prompt": prompt,
            "image_list": [imageUrl]
        ]
        
        if let sessionId = sessionId {
            input["session_id"] = sessionId
        }
        
        let requestBody: [String: Any] = [
            "parameters": [:],
            "biz_params": [
                "ScreenWidth": screenResolution.width,
                "ScreenHeight": screenResolution.height
            ],
            "debug": [:],
            "input": input
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw JsonError.invalidData
        }
        request.httpBody = jsonData
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let requestDataString = String(data: data, encoding: .utf8) {
            print("Response: \(requestDataString)")
        }
        
        let jsonDecoder = JSONDecoder()
        
        let decoded = try jsonDecoder.decode(QwenAiApiResponse.self, from: data)
        sessionId = decoded.output.session_id
        
        let jsonString = decoded.output.text.replacingOccurrences(of: "```json\n", with: "").replacingOccurrences(of: "\n```", with: "")
        guard let jsonData = jsonString.data(using: .utf8) else { throw JsonError.invalidData }
        
        return try jsonDecoder.decode(ApiResponse.self, from: jsonData)
    }
}
