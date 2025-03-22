//
//  ChatView.swift
//  AiAssistant
//
//  Created by Petru Grigor on 04.03.2025.
//

import Foundation
import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel = ChatViewModel()
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                ScrollView {
                    if viewModel.messages.isEmpty {
                        VStack {
                            Text("Start your chat with me!")
                                .padding(.top, 150)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    } else {
                        VStack(spacing: 20) {
                            ForEach(viewModel.messages, id: \.self) { message in
                                ChatMessageBubble(chatMessage: message)
                            }
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .foregroundStyle(.clear)
                                .id("BottomPadding")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .padding(.horizontal)
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
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 4) // 🔥 Added shadow
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit {
                                if viewModel.inputText.isEmpty { return }
                                viewModel.scrollToBottom(proxy: proxy)
                                Task {
                                    await viewModel.sendMessage()
                                }
                            }

                        Button(action: {
                            if viewModel.inputText.isEmpty { return }
                            viewModel.scrollToBottom(proxy: proxy)
                            Task {
                                await viewModel.sendMessage()
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
        .onAppear {
            InputController.shared.checkAccessibilityPermissions()
        }
    }
}
