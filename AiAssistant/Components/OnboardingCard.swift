import SwiftUI

struct OnboardingStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let buttonTitle: String
}

let onboardingSteps: [OnboardingStep] = [
    
    OnboardingStep(
        icon: "lock.shield.fill",
        title: "You're Always in Control",
        subtitle: "All actions require your approval. Agent AI never stores data or performs tasks silently. You can pause or revoke access at any time.",
        buttonTitle: "Next"
    ),
    OnboardingStep(icon: "", title: "", subtitle: "", buttonTitle: ""),
    OnboardingStep(
        icon: "hand.raised.fill",
        title: "Enable Accessibility",
        subtitle: "To control apps, click buttons, and type on your behalf, Agent AI needs Accessibility access.",
        buttonTitle: "Next"
    ),
    OnboardingStep(
        icon: "desktopcomputer",
        title: "Screen Access Needed",
        subtitle: "Agent AI needs permission to view your screen to understand and interact with apps. We use this only to assist you — never to record or store anything.",
        buttonTitle: "Done"
    ),
]

struct OnboardingCard: View {
    @State private var currentStep = 0
    
    @State private var activationCode = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.windowBackgroundColor))
                    .shadow(radius: 20)
                
                if currentStep == 1 {
                    VStack(spacing: 13) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 34, weight: .medium))
                            .padding(.top, 20)
                        
                        Text("Redeem Activation Code")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        
                        Text("If you already have a Pro code, enter it below to unlock premium features. You can skip this step if you don’t have one yet.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        TextField("e.g. PRO-4X9A-JK21", text: $activationCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .frame(height: 40)

                        Button(action: {
                            Task {
                                isLoading = true
                                do {
                                    try await UserApi.shared.redeemProCode(activationCode)
                                    alertMessage = "Code successfully redeemed!"
                                } catch {
                                    alertMessage = "Invalid or expired code. Please try again."
                                }
                                showAlert = true
                                isLoading = false
                            }
                        }) {
                            Text("Submit")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(activationCode.isEmpty)
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)

                        Button("Skip") {
                            withAnimation { currentStep += 1 }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                        HStack(spacing: 6) {
                            ForEach(0..<onboardingSteps.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentStep ? .white : .gray.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .frame(width: 360)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertMessage))
                    }
                } else {
                    VStack(spacing: 24) {
                        Image(systemName: onboardingSteps[currentStep].icon)
                            .font(.system(size: 32, weight: .medium))
                            .padding(.top, 20)
                        
                        Text(onboardingSteps[currentStep].title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        
                        Text(onboardingSteps[currentStep].subtitle)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation {
                                if currentStep == onboardingSteps.count - 2 {
                                    InputController.shared.checkAccessibilityPermissions()
                                }
                                
                                if currentStep < onboardingSteps.count - 1 {
                                    currentStep += 1
                                } else {
                                    ScreenCaptureController.shared.openScreenRecordingSettings()
                                    Constants.shared.completeOnboarding()
                                }
                            }
                        }) {
                            Text(onboardingSteps[currentStep].buttonTitle)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack(spacing: 6) {
                            ForEach(0..<onboardingSteps.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentStep ? .white : .gray.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .frame(width: 360)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 350)
        .task {
            try? await UserApi.shared.registerUser()
        }
    }
}
