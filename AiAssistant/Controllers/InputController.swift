//
//  InputController.swift
//  AiAssistant
//
//  Created by Petru Grigor on 05.03.2025.
//

import Foundation
import CoreGraphics
import Cocoa

final class InputController {
    static let shared = InputController()
    
    private init() {}
    
    func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        
        if accessibilityEnabled {
            print("✅ Accessibility permissions are granted.")
        } else {
            print("❌ Accessibility permissions are missing! Go to System Settings > Privacy & Security > Accessibility and allow access.")
        }
    }
    
    func clickMouse(at point: CGPoint) {
        let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
    
    @MainActor
    func executeAppleScript(_ script: String) {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
}
