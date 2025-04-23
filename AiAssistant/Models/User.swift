import Foundation

struct User: Codable, Identifiable {
    let id: String
    let isPro: Bool
    let registerDate: String
    let codeId: String?
    let code: String?
}
