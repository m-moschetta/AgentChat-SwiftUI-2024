//
//  N8NModels.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import Foundation

// MARK: - Basic N8N Models
struct N8NRequest: Codable {
    let message: String
    let chatId: String?
    let metadata: [String: String]
}

struct N8NResponse: Codable {
    let response: String
    let chatId: String?
    let metadata: [String: String]?
}