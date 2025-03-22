//
//  ChatViewModel.swift
//  AiAssistant
//
//  Created by Petru Grigor on 16.03.2025.
//

import Foundation
import SwiftUI

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var image: Image?
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo("BottomPadding")
        }
    }
    
    @MainActor
    func sendMessage() async {
        let temp = inputText
        inputText = ""
        
        let message = ChatMessage(id: UUID(), sendText: temp)
        self.messages.append(message)
        
        if let image = await ScreenCaptureController.shared.captureScreenshot() {
            do {
                let fileUrl = try await StorageApi.shared.uploadImage(image: image)
                
                let response = try await QwenAiApi.shared.getApiResponse(prompt: temp, imageUrl: "", screenResolution: image.size)
                messages[messages.count - 1].responseText = response.prompt
                
                if response.inputType == .mouse {
                    let point = CGPoint(x: response.mouseX ?? 0, y: response.mouseY ?? 0)
                    InputController.shared.clickMouse(at: point)
                } else { 
                    guard let script = response.appleScript else { return }
                    InputController.shared.executeAppleScript(script)
                }
            } catch {
                print("Ther was an error: \(error.localizedDescription)")
            }
        } else {
            print("There was an error capturing the screenshot.")
        }
    }
}
