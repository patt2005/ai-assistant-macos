import Foundation
import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel = ChatViewModel()
    
    @ObservedObject private var appState = AppState.shared
    
    @State private var gradientStops: [Gradient.Stop] = []
    
    private struct TypingIndicatorView: View {
        @State private var animate = false
        
        var body: some View {
            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animate ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(i) * 0.2),
                            value: animate
                        )
                }
            }
            .onAppear {
                animate = true
            }
            .padding(10)
            .background(Color(hex: "#4d4d4d").opacity(0.8))
            .cornerRadius(12)
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        if appState.messages.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.4))
                                
                                Text("Start by asking your assistant anything.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 75)
                        } else {
                            LazyVStack(alignment: .leading, spacing: 10) {
                                ForEach(appState.messages) { message in
                                    ChatMessageCard(message: message)
                                        .id(message.id)
                                }
                                
                                if viewModel.isLoading {
                                    TypingIndicatorView()
                                        .padding(.horizontal)
                                }
                            }
                            .onChange(of: appState.messages.count) { _ in
                                if let last = appState.messages.last {
                                    withAnimation {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
                HStack(spacing: 10) {
                    TextField("Type here...", text: $viewModel.inputText)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .textFieldStyle(PlainTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .onSubmit {
                            send()
                        }
                    
                    Button(action: send) {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .scaledToFit()
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 15, height: 15)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .foregroundColor(.black)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(viewModel.inputText.isEmpty ? 0.2 : 1)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 25)
            }
            .padding(.top, 70)
            .onAppear {
                if !appState.showOnboarding {
                    InputController.shared.checkAccessibilityPermissions()
                }
            }
        }
    }
    
    private func send() {
        guard !viewModel.inputText.isEmpty else { return }
        Task {
            await viewModel.sendMessage()
        }
    }
}
