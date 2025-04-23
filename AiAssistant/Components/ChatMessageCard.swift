import SwiftUI

struct ChatMessageCard: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.type == .system {
                Text(message.text)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
            } else {
                Spacer()
                Text(message.text)
                    .padding(8)
                    .foregroundColor(.white)
                    .background(
                        Color(hex: "#4d4d4d")
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 4)
    }
}
