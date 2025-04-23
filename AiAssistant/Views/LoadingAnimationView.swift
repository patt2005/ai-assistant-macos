import SwiftUI

struct LoadingAnimationView: View {
    @State private var rotation: CGFloat = 0.0
    
    var body: some View {
        if let screen = NSScreen.main {
            let visibleFrame = screen.visibleFrame
            
            ZStack {
                Color.clear
                
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .frame(width: visibleFrame.width * 2, height: visibleFrame.height * 0.5)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "BC82F3"), Color(hex: "F5B9EA"),
                                Color(hex: "8D9FFF"), Color(hex: "FF6778"),
                                Color(hex: "FFBA71"), Color(hex: "C686FF")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(rotation))
                    .mask(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(lineWidth: 5)
                            .frame(width: visibleFrame.width * 0.997, height: visibleFrame.height * 0.997)
                    )
                    .position(x: visibleFrame.width / 2, y: visibleFrame.height / 2)
            }
            .background(Color.clear)
            .onAppear {
                withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}
