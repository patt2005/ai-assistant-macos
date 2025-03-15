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
}

enum JsonError: Error {
    case invalidData
}

enum ChatMessageError: Error {
    case invalidHttpResponse
    case invalidData
}
