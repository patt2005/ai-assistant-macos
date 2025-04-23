import Foundation
import SwiftUI

final class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    
    @ObservedObject private var appState = AppState.shared
    
    @MainActor
    func sendMessage() async {
        if !Constants.shared.canSendMessage {
            appState.showLimitReachedPopup = true
            return
        }
        
        let temp = inputText
        inputText = ""
        isLoading = true
        
        let message = ChatMessage(id: UUID(), text: temp, type: .user)
        appState.messages.append(message)
        
        AppDelegate.shared.showLoadingAnimation()
        
        do {
            try await ChatGptApi.shared.runComputerUseLoop(prompt: temp)
            
            Constants.shared.incrementFreeMessageCount()
        } catch {
            appState.messages.append(ChatMessage(id: UUID(), text: "There was an error processing your request. Please try again later.", type: .system))
            appState.showNewTaskButton = true
            bringAppToFront()
            
            print("Error: \(error.localizedDescription)")
        }
        
        AppDelegate.shared.hideLoadingAnimation()
        isLoading = false
    }
}
