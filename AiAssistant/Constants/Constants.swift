//
//  Constants.swift
//  AiAssistant
//
//  Created by Petru Grigor on 04.03.2025.
//

import Foundation

final class Constants {
    static let shared = Constants()
    
    private init () {}
    
    let qwenAiApi = ""
    let applicationId = "5b689da750f5434587990496488a8e00"
}

enum JsonError: Error {
    case invalidData
}

enum ChatMessageError: Error {
    case invalidHttpResponse
    case invalidData
}

enum InputType: String, Decodable {
    case mouse = "mouse"
    case keyboard = "keyboard"
}
