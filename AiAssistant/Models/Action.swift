import Foundation

struct Action: Codable {
    struct CoordinatesPath: Codable {
        let x: Int
        let y: Int
    }
    
    let type: InputType
    let x: Int?
    let y: Int?
    let scroll_x: Int?
    let scroll_y: Int?
    let button: String?
    let keys: [String]?
    let text: String?
    let path: [CoordinatesPath]?
}
