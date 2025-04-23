import Foundation
import SwiftUI

final class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var lastCallId: String? = nil
    @Published var previousCallId: String? = nil
    
    @Published var isAwaitingConfirmation = false
    
    @Published var messages: [ChatMessage] = []
    
    @Published var showOnboarding: Bool = false
    
    @Published var showNewTaskButton: Bool = false
    
    @Published var showSettingsPopup: Bool = false
    
    @Published var acknlownedSafetyChecks: [SafetyCheck] = []
    
    @Published var isProUser = false
    
    @Published var showLimitReachedPopup: Bool = false
}
