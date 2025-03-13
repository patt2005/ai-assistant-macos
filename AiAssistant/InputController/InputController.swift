//
//  InputController.swift
//  AiAssistant
//
//  Created by Petru Grigor on 05.03.2025.
//

import Foundation
import CoreGraphics

final class InputController {
    static let shared = InputController()
    
    private init() {}
    
    func moveMouse(to point: CGPoint) {
        let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left)
        event?.post(tap: .cghidEventTap)
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
