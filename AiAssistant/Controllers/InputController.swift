import Foundation
import CoreGraphics
import Cocoa

final class InputController {
    static let shared = InputController()
    
    private init() {}
    
    func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
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
    
    func scrollBy(x: Int32, y: Int32) {
        let scrollEvent = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: y,
            wheel2: x,
            wheel3: 0
        )
        
        scrollEvent?.post(tap: .cghidEventTap)
    }
    
    func dragMouse(along path: [CGPoint]) {
        guard path.count > 1 else { return }
        
        CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: path[0], mouseButton: .left)?.post(tap: .cghidEventTap)
        
        CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: path[0], mouseButton: .left)?.post(tap: .cghidEventTap)
        
        for point in path.dropFirst() {
            CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: point, mouseButton: .left)?.post(tap: .cghidEventTap)
            usleep(5000)
        }
        
        if let last = path.last {
            CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: last, mouseButton: .left)?.post(tap: .cghidEventTap)
        }
    }
    
    func handleModelAction(_ action: Action) {
        switch action.type {
        case .click:
            guard let x = action.x, let y = action.y else { return }
            let point = CGPoint(x: x, y: y)
            print("🖱️ Click at (\(x), \(y))")
            InputController.shared.clickMouse(at: point)
            
        case .scroll:
            guard let scrollX = action.scroll_x, let scrollY = action.scroll_y else { return }
            print("🖱️ Scroll by (\(scrollX), \(scrollY))")
            InputController.shared.scrollBy(x: Int32(scrollX), y: Int32(scrollY))
            
        case .keypress:
            guard let keys = action.keys else { return }
            print("⌨️ Press keys:", keys.joined(separator: " + "))
            InputController.shared.pressKeys(keys: keys)
            
        case .type:
            guard let text = action.text else { return }
            print("⌨️ Typing text: \(text)")
            InputController.shared.executeAppleScript("""
            tell application "System Events"
                keystroke "\(text)"
            end tell
            """)
            
        case .drag:
            if let path = action.path {
                let points = path.map { coordinate in
                    CGPoint(x: coordinate.x, y: coordinate.y)
                }
                print("🖱️ Drag mouse")
                
                InputController.shared.dragMouse(along: points)
            }
            
        case .wait:
            print("⏱️ Waiting 2 seconds")
            Thread.sleep(forTimeInterval: 2)
            
        case .screenshot:
            print("📸 Screenshot requested – already handled during input, no action needed.")
        }
    }
    
    func pressKeys(keys: [String]) {
        let lowercasedKeys = keys.map { $0.lowercased() }
        
        if lowercasedKeys.count == 1 {
            switch lowercasedKeys[0] {
            case "enter", "return":
                executeAppleScript("""
                tell application "System Events" to key code 36
                """)
                return
            case "escape", "esc":
                executeAppleScript("""
                tell application "System Events" to key code 53
                """)
                return
            case "tab":
                executeAppleScript("""
                tell application "System Events" to key code 48
                """)
                return
            case "delete":
                executeAppleScript("""
                tell application "System Events" to key code 51
                """)
                return
            default:
                break
            }
        }
        
        var modifiers: [String] = []
        var targetKey = ""
        
        for key in lowercasedKeys {
            if let mapped = Constants.shared.cuaToAppleScriptKey[key] {
                if mapped.hasSuffix("down") {
                    modifiers.append(mapped)
                } else {
                    targetKey = mapped
                }
            } else {
                targetKey = key
            }
        }
        
        guard !targetKey.isEmpty else {
            executeAppleScript("""
            tell application "System Events"
                key down {\(modifiers.joined(separator: ", "))}
            end tell
            """)
            return
        }
        
        executeAppleScript("""
        tell application "System Events"
            keystroke "\(targetKey)" using {\(modifiers.joined(separator: ", "))}
        end tell
        """)
    }
    
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
