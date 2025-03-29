//
//  StorageApi.swift
//  AiAssistant
//
//  Created by Petru Grigor on 16.03.2025.
//

import Foundation
import SwiftUI

final class StorageApi {
    static let shared = StorageApi()
    
    private init() {}
    
    private struct ApiResponse: Decodable {
        let message: String
        let fileName: String
    }
    
    private let baseUrl = "https://ai-assistant-backend-164860087792.us-central1.run.app"
    
    func uploadImage(image: NSImage) async throws -> String {
        let url = URL(string: "\(baseUrl)/api/file/upload-file")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "ImageConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert NSImage to PNG"])
        }

        let fileName = "\(UUID()).png"
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(pngData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(ApiResponse.self, from: data)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "UploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"])
        }

        return "https://storage.googleapis.com/ai-assistant-macos-app/\(decoded.fileName)"
    }
}
