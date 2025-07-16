//
//  N8NService.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import Foundation

class N8NService: ObservableObject {
    static let shared = N8NService()
    
    @Published var webhookURL: String = ""
    @Published var isConfigured: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let webhookURLKey = "n8n_webhook_url"
    
    private init() {
        loadConfiguration()
    }
    
    func loadConfiguration() {
        webhookURL = userDefaults.string(forKey: webhookURLKey) ?? ""
        isConfigured = !webhookURL.isEmpty
    }
    
    func saveConfiguration() {
        userDefaults.set(webhookURL, forKey: webhookURLKey)
        isConfigured = !webhookURL.isEmpty
    }
    
    func updateWebhookURL(_ url: String) {
        webhookURL = url
        saveConfiguration()
    }
    
    func sendMessage(_ message: String, chatId: String? = nil) async throws -> String {
        guard !webhookURL.isEmpty else {
            throw N8NError.webhookNotConfigured
        }
        
        guard let url = URL(string: webhookURL) else {
            throw N8NError.invalidWebhookURL
        }
        
        let request = N8NRequest(
            message: message,
            chatId: chatId,
            metadata: ["timestamp": ISO8601DateFormatter().string(from: Date())]
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw N8NError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw N8NError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw N8NError.httpError(httpResponse.statusCode)
        }
        
        do {
            let n8nResponse = try JSONDecoder().decode(N8NResponse.self, from: data)
            return n8nResponse.response
        } catch {
            // If decoding fails, try to return raw response as string
            if let responseString = String(data: data, encoding: .utf8) {
                return responseString
            } else {
                throw N8NError.decodingError
            }
        }
    }
    
    func testConnection() async throws -> Bool {
        let testMessage = "Test connection"
        _ = try await sendMessage(testMessage)
        return true
    }
}

enum N8NError: Error, LocalizedError {
    case webhookNotConfigured
    case invalidWebhookURL
    case encodingError
    case decodingError
    case invalidResponse
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .webhookNotConfigured:
            return "N8N webhook URL is not configured. Please set it in settings."
        case .invalidWebhookURL:
            return "Invalid N8N webhook URL."
        case .encodingError:
            return "Failed to encode N8N request."
        case .decodingError:
            return "Failed to decode N8N response."
        case .invalidResponse:
            return "Invalid response from N8N webhook."
        case .httpError(let code):
            return "N8N HTTP error: \(code)"
        }
    }
}