import Foundation

final class Constants {
    static let shared = Constants()
    
    private init () {}
    
    var userId: UUID? = nil
    private let userIdKey = "userId"
    
    let apiBaseUrl = "https://agent-ai-7kzmirsbfq-uc.a.run.app"
    
    var apiKey = ""
    
    let cuaToAppleScriptKey: [String: String] = [
        "/": "slash",
        "\\": "backslash",
        "alt": "option down",
        "option": "option down",
        "shift": "shift down",
        "cmd": "command down",
        "command": "command down",
        "ctrl": "command down",
        "super": "command down",
        "win": "command down",
        "meta": "command down",
        "arrowdown": "down arrow",
        "arrowleft": "left arrow",
        "arrowright": "right arrow",
        "arrowup": "up arrow",
        "backspace": "delete",
        "delete": "forward delete",
        "capslock": "caps lock",
        "enter": "return",
        "esc": "escape",
        "home": "home",
        "end": "end",
        "insert": "help",
        "pagedown": "page down",
        "pageup": "page up",
        "space": "space",
        "tab": "tab"
    ]
    
    private let freeMessageLimit = 5
    private let messageCountKey = "freeMessageCount"

    var remainingFreeMessages: Int {
        max(0, freeMessageLimit - UserDefaults.standard.integer(forKey: messageCountKey))
    }

    var canSendMessage: Bool {
        return AppState.shared.isProUser == true || remainingFreeMessages > 0
    }

    func incrementFreeMessageCount() {
        guard AppState.shared.isProUser != true else { return }
        
        let currentCount = UserDefaults.standard.integer(forKey: messageCountKey)
        if currentCount < freeMessageLimit {
            UserDefaults.standard.set(currentCount + 1, forKey: messageCountKey)
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        AppState.shared.showOnboarding = false
    }
    
    func loadConfig() {
        AppState.shared.showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingCompleted")
        
        if let savedId = UserDefaults.standard.string(forKey: userIdKey),
           let uuid = UUID(uuidString: savedId) {
            self.userId = uuid
        } else {
            let newId = UUID()
            self.userId = newId
            UserDefaults.standard.set(newId.uuidString, forKey: userIdKey)
        }
    }
}

enum ApiResponseStatus: String, Codable {
    case completed
    case reasoning
}

enum MessageType: String, Codable {
    case user
    case system
}

enum ApiError: Error {
    case decodingFailed
    case invalidResponse
    case encodingFailded
}

enum OutputType: String, Codable {
    case message
    case function_call
    case computer_call
    case reasoning
}

enum InputType: String, Codable {
    case click
    case scroll
    case keypress
    case type
    case wait
    case screenshot
    case drag
}

enum MouseButton: String, Decodable {
    case left
    case right
}

