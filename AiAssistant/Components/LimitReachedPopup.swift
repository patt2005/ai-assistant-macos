import SwiftUI

struct LimitReachedPopup: View {
    private func onUnlock() {
        if let url = URL(string: "\(Constants.shared.apiBaseUrl)/api/checkout/checkout") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func onDismiss() {
        withAnimation {
            AppState.shared.showLimitReachedPopup = false
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.yellow)
            
            Text("Limit Reached")
                .font(.title2.bold())
            
            Text("You’ve used all 5 free tasks.\nUpgrade to Pro to continue using Agent AI.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: onUnlock) {
                Text("Unlock Pro")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .cornerRadius(13)
            }
            .padding(.horizontal)
            .buttonStyle(PlainButtonStyle())
            
            Button("Not Now") {
                onDismiss()
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding(30)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 16)
        )
    }
}
