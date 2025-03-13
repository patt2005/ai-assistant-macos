//
//  ChatMessageBubble.swift
//  AiAssistant
//
//  Created by Petru Grigor on 04.03.2025.
//

import Foundation
import SwiftUI

struct ChatMessageBubble: View {
    @ObservedObject var chatMessage: ChatMessage
    
    private struct LoadingAnimation: View {
        @State private var scaleEffect: CGFloat = 1
        @State private var opacity: Double = 1
        
        private func resetAnimation() async {
            scaleEffect = 0.7
            opacity = 0.7
            try? await Task.sleep(nanoseconds: 500_000_000)
            scaleEffect = 1.0
            opacity = 1.0
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        var body: some View {
            Circle()
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
                .scaleEffect(scaleEffect)
                .opacity(opacity)
                .animation(.easeInOut, value: scaleEffect)
                .animation(.easeInOut, value: opacity)
                .task {
                    while true {
                        await resetAnimation()
                    }
                }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                
                Text(chatMessage.sendText)
                    .padding(10)
                    .background(.gray.opacity(0.6))
                    .cornerRadius(13)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
            }
            
            HStack {
                if let responseText = chatMessage.responseText {
                    Text(responseText)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                } else {
                    LoadingAnimation()
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
