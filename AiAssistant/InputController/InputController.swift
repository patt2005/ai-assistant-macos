//
//  InputController.swift
//  AiAssistant
//
//  Created by Petru Grigor on 05.03.2025.
//

import Foundation
import CoreGraphics
import Cocoa
import ScreenCaptureKit

final class InputController {
    static let shared = InputController()
    
    private init() {}
    
    func checkScreenRecordingPermissions() {
        if CGPreflightScreenCaptureAccess() {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Screen Recording Permission Required"
                alert.informativeText = "To capture the screen, enable screen recording in System Settings → Privacy & Security → Screen Recording."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Open Settings")
                alert.addButton(withTitle: "Cancel")
                
                let response = alert.runModal()
                
                if response == .alertFirstButtonReturn {
                    self.openSystemSettings()
                }
            }
        }
    }
    
    private func captureWithScreenCaptureKit() -> NSImage? {
        return nil
    }
    
    private func captureWithCGImage() -> NSImage? {
        return nil
    }
    
    func captureScreen() -> NSImage? {
        if #available(macOS 15.0, *) {
            return captureWithScreenCaptureKit()
        }
        return captureWithCGImage()
    }
    
    private func openSystemSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
        NSWorkspace.shared.open(url)
    }
    
    func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        
        if accessibilityEnabled {
            print("✅ Accessibility permissions are granted.")
        } else {
            print("❌ Accessibility permissions are missing! Go to System Settings > Privacy & Security > Accessibility and allow access.")
        }
    }
    
    func moveMouse(to point: CGPoint) {
        let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left)
        if let event = event {
            event.post(tap: .cghidEventTap)
        } else {
            print("Error creating event")
        }
    }
    
    func clickMouse(at point: CGPoint) {
        let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
    
    func typeString(_ text: String) {
        let launchScript = """
            tell application "System Events"
                if not (exists process "System Events") then
                    launch
                    delay 0.5
                end if
                keystroke "\(text)"
            end tell
        """
        
        DispatchQueue.main.async {
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: launchScript) {
                scriptObject.executeAndReturnError(&error)
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
}
