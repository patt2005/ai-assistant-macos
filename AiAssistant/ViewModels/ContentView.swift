import SwiftUI
import AppKit

class FocusableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

struct ContentView: View {
    @ObservedObject private var appState = AppState.shared
    
    private func configureWindowStyle() {
        if let window = NSApplication.shared.windows.first {
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            
            window.styleMask.remove(.resizable)
            window.styleMask.remove(.titled)
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "#323232"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(radius: 5)
                .padding(12.5)
            
            ChatView()
            
            VStack {
                ZStack {
                    Text("Agent AI")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .fontWeight(.semibold)
                        .padding(.top, 20)
                    
                    HStack {
                        Button(action: {
                            NSApp.keyWindow?.close()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 25)
                                .padding(.top, 22.5)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        if appState.showNewTaskButton {
                            Button(action: resetTask) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Task")
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color(hex: "4d4d4d"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding([.top, .trailing], 22)
                            }
                            .transition(.opacity)
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Button(action: {
                            appState.showSettingsPopup = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 22.5)
                                .padding(.trailing, 25)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            
            if appState.isAwaitingConfirmation {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black.opacity(0.5))
                    .padding(12.5)
                
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow)
                        
                        Text("Confirm Sensitive Action")
                            .font(.title3)
                            .bold()
                    }
                    
                    Text("The assistant is about to perform a potentially sensitive action.\nPlease confirm you want to continue.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                    
                    HStack(spacing: 16) {
                        Button {
                            appState.isAwaitingConfirmation = false
                        } label: {
                            Text("Cancel Task")
                                .fontWeight(.medium)
                                .frame(minWidth: 120)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                        
                        Button {
                            appState.isAwaitingConfirmation = false
                            hideAppWindow()
                            
                            Task {
                                do {
                                    try await ChatGptApi.shared.runComputerUseLoop(prompt: "")
                                } catch {
                                    appState.messages.append(ChatMessage(
                                        id: UUID(),
                                        text: "There was an error processing your request. Please try again later.",
                                        type: .system
                                    ))
                                    appState.showNewTaskButton = true
                                    bringAppToFront()
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        } label: {
                            Label("Approve & Continue", systemImage: "checkmark.seal.fill")
                                .frame(minWidth: 180)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.regular)
                    }
                }
                .padding(32)
                .frame(width: 420)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(NSColor.windowBackgroundColor))
                        .shadow(radius: 10)
                )
                .padding()
            }
            
            if appState.showSettingsPopup {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black.opacity(0.5))
                    .padding(12.5)
                
                SettingsCard()
            }
            
            if appState.showOnboarding {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black.opacity(0.5))
                    .padding(12.5)
                
                OnboardingCard()
            }
            
            if appState.showLimitReachedPopup {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black.opacity(0.5))
                    .padding(12.5)
                
                LimitReachedPopup()
            }
        }
        .background(Color.clear)
        .onAppear {
            configureWindowStyle()
        }
    }
    
    private func resetTask() {
        withAnimation {
            appState.messages.removeAll()
            appState.lastCallId = nil
            appState.previousCallId = nil
            appState.acknlownedSafetyChecks.removeAll()
        }
    }
}
