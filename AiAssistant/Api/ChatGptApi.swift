import Foundation
import SwiftUI

final class ChatGptApi {
    static let shared = ChatGptApi()
    
    @ObservedObject private var appState = AppState.shared
    
    struct Output: Codable {
        struct Summary: Codable {
            let type, text: String
        }
        
        struct Content: Codable {
            let type, text: String
        }
        
        let id: String
        let type: OutputType
        let summary: [Summary]?
        let status: ApiResponseStatus?
        let action: Action?
        let callID: String?
        let pendingSafetyChecks: [SafetyCheck]?
        let content: [Content]?
        
        enum CodingKeys: String, CodingKey {
            case id, type, summary, status, action
            case callID = "call_id"
            case pendingSafetyChecks = "pending_safety_checks"
            case content
        }
    }
    
    struct ApiResponse: Codable {
        let id : String
        let status: ApiResponseStatus
        let output: [Output]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.status = try container.decode(ApiResponseStatus.self, forKey: .status)
            
            let outputList = try container.decodeIfPresent([Output?].self, forKey: .output) ?? []
            self.output = outputList.compactMap { $0 }
        }
    }
    
    func runComputerUseLoop(prompt: String) async throws {
        guard let firstScreenshot = await ScreenCaptureController.shared.captureScreenshot() else {
            throw ApiError.decodingFailed
        }
        
        let safeGuardingInstruction = """
        !!! Only ask for confirmation or interact with sensitive UI (e.g. passwords, payments, passport info) if absolutely required.
        If you're just browsing, reading, or searching — continue automatically. Skip prompts unless critical !!!
        """
        
        let fullPrompt = safeGuardingInstruction + "\n\n" + prompt
        
        var response: ApiResponse? = try await ChatGptApi.shared.sendComputerUseRequest(prompt: prompt.isEmpty ? prompt : fullPrompt, image: firstScreenshot)
        
        while let computerCall = response?.output.first(where: { $0.type == .computer_call && $0.action != nil }) {
            guard let action = computerCall.action,
                  let callId = computerCall.callID else { break }
            
            response?.output.forEach { output in
                if let text = output.content?.first?.text {
                    appState.messages.append(ChatMessage(id: UUID(), text: text, type: .system))
                }
            }
            
            appState.lastCallId = callId
            appState.previousCallId = response?.id
            
            InputController.shared.handleModelAction(action)
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            guard let screenshotImage = await ScreenCaptureController.shared.captureScreenshot() else {
                print("❌ Could not capture screenshot.")
                break
            }
            
            let newChecks = computerCall.pendingSafetyChecks ?? []
            
            if !newChecks.isEmpty {
                for check in newChecks {
                    let systemMessage = ChatMessage(
                        id: UUID(),
                        text: "⚠️ \(check.message)\nTap 'Approve' to continue or 'Cancel' to stop.",
                        type: .system
                    )
                    appState.messages.append(systemMessage)
                    appState.acknlownedSafetyChecks.append(check)
                }
                
                appState.isAwaitingConfirmation = true
                break
            }
            
            response = try await ChatGptApi.shared.sendComputerUseRequest(
                prompt: "",
                image: screenshotImage
            )
        }
        
        response?.output.forEach { output in
            if let text = output.content?.first?.text {
                appState.messages.append(ChatMessage(id: UUID(), text: text, type: .system))
            }
        }
        
        appState.showNewTaskButton = true
        bringAppToFront()
        
        print("✅ Loop finished — no more computer calls.")
    }
    
    private func sendComputerUseRequest(prompt: String, image: NSImage) async throws -> ApiResponse {
        let base64 = nsImageToBase64(image) ?? ""

        let checksArray = appState.acknlownedSafetyChecks.map {
            ["id": $0.id, "code": $0.code, "message": $0.message]
        }

        var input: [[String: Any]] = []

        if let lastCallId = appState.lastCallId {
            var toolOutput: [String: Any] = [
                "type": "computer_call_output",
                "call_id": lastCallId,
                "output": [
                    "type": "input_image",
                    "image_url": "data:image/png;base64,\(base64)"
                ]
            ]

            if !checksArray.isEmpty {
                toolOutput["acknowledged_safety_checks"] = checksArray
            }

            input.append(toolOutput)

            if !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                input.append([
                    "role": "user",
                    "content": prompt
                ])
            }

            appState.acknlownedSafetyChecks.removeAll()
        } else {
            input = [[
                "role": "user",
                "content": prompt
            ]]
        }

        var requestBody: [String: Any] = [
            "model": "computer-use-preview",
            "tools": [[
                "type": "computer_use_preview",
                "display_width": Int(image.size.width),
                "display_height": Int(image.size.height),
                "environment": "mac"
            ]],
            "input": input,
            "truncation": "auto"
        ]

        if let previousId = appState.previousCallId {
            requestBody["previous_response_id"] = previousId
        }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.shared.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [.prettyPrinted])

        let (data, _) = try await URLSession.shared.data(for: request)
        
        print(String(data: data, encoding: .utf8) ?? "No data")

        return try JSONDecoder().decode(ApiResponse.self, from: data)
    }
}
