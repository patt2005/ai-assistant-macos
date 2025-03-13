//
//  ChatView.swift
//  AiAssistant
//
//  Created by Petru Grigor on 04.03.2025.
//

import Foundation
import SwiftUI

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    
    @MainActor
    func sendMessage() async {
        let text = inputText
        inputText = ""
        let chatMessage = ChatMessage(id: UUID(), sendText: text, responseText: nil)
        self.messages.append(chatMessage)
        
        var streamText = ""
        
        do {
            let stream = try await OpenAiApi.shared.getChatResponse(prompt: text)
            for try await line in stream {
                streamText += line
                self.messages[self.messages.count - 1].responseText = streamText
            }
        } catch {
            print("There was an error: \(error)")
        }
    }
}

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel = ChatViewModel()
    
    var body: some View {
        ZStack {
            ScrollView {
                if viewModel.messages.isEmpty {
                    VStack {
                        Text("Start your chat with me!")
                    }
                    .padding(.top, 200)
                } else {
                    VStack(spacing: 20) {
                        ForEach(viewModel.messages, id: \.self) { message in
                            ChatMessageBubble(chatMessage: message)
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal)
                    .padding(.bottom, 65)
                }
            }
            
            VStack {
                Spacer()
                
                HStack {
                    TextField("Type here...", text: $viewModel.inputText)
                        .padding(.leading, 12)
                        .padding(.vertical, 10)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.5), lineWidth: 1))
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            Task {
                                await viewModel.sendMessage()
                            }
                        }
                    
                    Button(action: {
                        InputController.shared.moveMouse(to: CGPoint(x: 300, y: 300))
//                        Task {
//                            await viewModel.sendMessage()
//                        }
                        Task {
//                            for i in 0..<10 {
//                                if i == 7 {
//                                    try? await Task.sleep(nanoseconds: 500_000_000)
//                                    InputController.shared.clickMouse(at: CGPoint(x: i * 9, y: i * 9))
//                                    try? await Task.sleep(nanoseconds: 500_000_000)
//                                    InputController.shared.clickMouse(at: CGPoint(x: i * 9, y: i * 9))
//                                } else {
//                                    try? await Task.sleep(nanoseconds: 500_000_000)
//                                    InputController.shared.moveMouse(to: CGPoint(x: i * 9, y: i * 9))
//                                }
//                            }
                            
//                            InputController.shared.typeString("Hello Peter!")
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(10)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
        }
    }
}
