import Foundation
import SwiftUI

let windowWidth: CGFloat = 700
let windowHeight: CGFloat = 400

func nsImageToBase64(_ image: NSImage) -> String? {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        return nil
    }
    
    return pngData.base64EncodedString()
}

func bringAppToFront() {
    if let win = AppDelegate.shared.window {
        if win.canBecomeMain, win.canBecomeKey {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            print("⚠️ Window can't become key or main")
        }
    } else {
        print("⚠️ No main window to bring to front")
    }
}

func hideAppWindow() {
    if let window = NSApp.windows.first {
        window.orderOut(nil)
    }
}

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        guard hexString.count == 6 else {
            self.init(.clear)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
