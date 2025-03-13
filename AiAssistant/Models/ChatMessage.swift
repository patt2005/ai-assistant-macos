//
//  ChatMessage.swift
//  AiAssistant
//
//  Created by Petru Grigor on 04.03.2025.
//

import Foundation

final class ChatMessage: Identifiable, Hashable, Equatable, ObservableObject {
    let id: UUID
    let sendText: String
    @Published var responseText: String?
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: UUID, sendText: String, responseText: String? = nil) {
        self.sendText = sendText
        self.responseText = responseText
        self.id = id
    }
}
