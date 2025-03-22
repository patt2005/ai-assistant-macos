//
//  ApiResponse.swift
//  AiAssistant
//
//  Created by Petru Grigor on 16.03.2025.
//

import Foundation

final class ApiResponse: Decodable {
    let inputType: InputType
    let appleScript: String?
    let prompt: String
    let isFinal: Bool
    let mouseX: Double?
    let mouseY: Double?
    
    init(inputType: InputType, appleScript: String?, prompt: String, isFinal: Bool, mouseX: Double?, mouseY: Double?) {
        self.inputType = inputType
        self.appleScript = appleScript
        self.prompt = prompt
        self.isFinal = isFinal
        self.mouseX = mouseX
        self.mouseY = mouseY
    }
}
