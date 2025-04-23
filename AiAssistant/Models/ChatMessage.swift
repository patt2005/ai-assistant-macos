import Foundation

final class ChatMessage: Identifiable, Hashable, Equatable {
    let id: UUID
    let text: String
    let type: MessageType
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: UUID, text: String, type: MessageType) {
        self.id = id
        self.text = text
        self.type = type
    }
}
