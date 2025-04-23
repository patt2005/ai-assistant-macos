import SwiftUI

struct SettingsCard: View {
    @ObservedObject private var appState = AppState.shared
    @State private var showRedeemPopup = false
    @State private var activationCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let baseUrl = "https://agent-ai-7kzmirsbfq-uc.a.run.app"

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(radius: 30)

            VStack(spacing: 20) {
                Text("Settings")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.top, 12)

                VStack(spacing: 12) {
                    if !appState.isProUser {
                        settingButton(title: "Redeem Activation Code") {
                            showRedeemPopup = true
                        }
                    }

                    settingButton(title: "Contact Us") {
                        openUrl("mailto:petru@codbun.com")
                    }

                    settingButton(title: "Privacy Policy") {
                        openUrl("\(baseUrl)/privacy")
                    }

                    settingButton(title: "Terms of Use") {
                        openUrl("\(baseUrl)/terms")
                    }
                }

                Divider().padding(.horizontal)

                Button("Close") {
                    appState.showSettingsPopup = false
                }
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.15))
                .foregroundColor(.primary)
                .cornerRadius(10)
                .buttonStyle(.plain)
                .padding(.bottom, 16)
            }
            .padding()
            .frame(width: 340, height: 320)
        }
        .overlay(redeemPopupOverlay)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
    }

    // MARK: - Redeem Popup Overlay
    private var redeemPopupOverlay: some View {
        Group {
            if showRedeemPopup {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .blur(radius: 2)
                        .onTapGesture {
                            showRedeemPopup = false
                            activationCode = ""
                        }

                    VStack(spacing: 20) {
                        Text("Enter Activation Code")
                            .font(.title3.bold())

                        TextField("e.g. PRO-1234-ABCD", text: $activationCode)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 280)

                        HStack(spacing: 16) {
                            Button("Cancel") {
                                showRedeemPopup = false
                                activationCode = ""
                            }
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.bordered)

                            Button("Submit") {
                                Task {
                                    do {
                                        try await UserApi.shared.redeemProCode(activationCode)
                                        alertMessage = "Code successfully redeemed!"
                                    } catch {
                                        alertMessage = "Failed to redeem code. Please try again."
                                    }
                                    showRedeemPopup = false
                                    showAlert = true
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(width: 280)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 16)
                    )
                    .frame(width: 320)
                }
            }
        }
    }

    // MARK: - Setting Button
    private func settingButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.08))
                    )
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }

    private func openUrl(_ url: String) {
        if let url = URL(string: url) {
            NSWorkspace.shared.open(url)
        }
    }
}
