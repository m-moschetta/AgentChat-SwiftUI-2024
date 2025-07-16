//
//  N8NAgentService.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import Foundation

class N8NAgentService: ObservableObject {
    static let shared = N8NAgentService()
    
    @Published var agentConfigurations: [N8NAgentConfiguration] = []
    @Published var isConfigured: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let configurationsKey = "n8n_agent_configurations"
    
    private init() {
        loadConfigurations()
    }
    
    func loadConfigurations() {
        if let data = userDefaults.data(forKey: configurationsKey),
           let decoded = try? JSONDecoder().decode([N8NAgentConfiguration].self, from: data) {
            agentConfigurations = decoded
        }
        updateConfigurationStatus()
    }
    
    func saveConfigurations() {
        if let encoded = try? JSONEncoder().encode(agentConfigurations) {
            userDefaults.set(encoded, forKey: configurationsKey)
        }
        updateConfigurationStatus()
    }
    
    private func updateConfigurationStatus() {
        isConfigured = !agentConfigurations.isEmpty && agentConfigurations.contains { $0.isActive }
    }
    
    func addConfiguration(_ configuration: N8NAgentConfiguration) {
        agentConfigurations.append(configuration)
        saveConfigurations()
    }
    
    func removeConfiguration(at index: Int) {
        guard index < agentConfigurations.count else { return }
        agentConfigurations.remove(at: index)
        saveConfigurations()
    }
    
    func updateConfiguration(at index: Int, with configuration: N8NAgentConfiguration) {
        guard index < agentConfigurations.count else { return }
        agentConfigurations[index] = configuration
        saveConfigurations()
    }
    
    func getActiveConfigurations() -> [N8NAgentConfiguration] {
        return agentConfigurations.filter { $0.isActive }
    }
    
    func sendMessage(to configurationId: UUID, message: String, chatId: String? = nil) async throws -> String {
        guard let configuration = agentConfigurations.first(where: { $0.id == configurationId }) else {
            throw N8NAgentError.configurationNotFound
        }
        
        guard configuration.isActive else {
            throw N8NAgentError.configurationInactive
        }
        
        guard let url = URL(string: configuration.webhookURL) else {
            throw N8NAgentError.invalidWebhookURL
        }
        
        let request = N8NAgentRequest(
            message: message,
            chatId: chatId,
            agentId: configuration.agentId,
            metadata: configuration.metadata
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers if configured
        for (key, value) in configuration.customHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw N8NAgentError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw N8NAgentError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw N8NAgentError.httpError(httpResponse.statusCode)
        }
        
        do {
            let agentResponse = try JSONDecoder().decode(N8NAgentResponse.self, from: data)
            return agentResponse.response
        } catch {
            // If decoding fails, try to return raw response as string
            if let responseString = String(data: data, encoding: .utf8) {
                return responseString
            } else {
                throw N8NAgentError.decodingError
            }
        }
    }
    
    func testConfiguration(_ configuration: N8NAgentConfiguration) async throws -> Bool {
        let testMessage = "Test connection for agent: \(configuration.name)"
        _ = try await sendMessage(to: configuration.id, message: testMessage)
        return true
    }
    
    override func validateConfiguration() {
        // Validation logic for N8N agent configurations
        for configuration in agentConfigurations {
            if configuration.webhookURL.isEmpty {
                print("Warning: Configuration \(configuration.name) has empty webhook URL")
            }
        }
    }
}

// MARK: - N8N Agent Models
struct N8NAgentConfiguration: Identifiable, Codable {
    let id = UUID()
    var name: String
    var agentId: String
    var webhookURL: String
    var description: String
    var isActive: Bool
    var customHeaders: [String: String]
    var metadata: [String: String]
    
    init(name: String, agentId: String, webhookURL: String, description: String = "", isActive: Bool = true, customHeaders: [String: String] = [:], metadata: [String: String] = [:]) {
        self.name = name
        self.agentId = agentId
        self.webhookURL = webhookURL
        self.description = description
        self.isActive = isActive
        self.customHeaders = customHeaders
        self.metadata = metadata
    }
}

struct N8NAgentRequest: Codable {
    let message: String
    let chatId: String?
    let agentId: String
    let metadata: [String: String]
}

struct N8NAgentResponse: Codable {
    let response: String
    let agentId: String?
    let chatId: String?
    let metadata: [String: String]?
}

enum N8NAgentError: Error, LocalizedError {
    case configurationNotFound
    case configurationInactive
    case invalidWebhookURL
    case encodingError
    case decodingError
    case invalidResponse
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .configurationNotFound:
            return "N8N agent configuration not found."
        case .configurationInactive:
            return "N8N agent configuration is inactive."
        case .invalidWebhookURL:
            return "Invalid N8N agent webhook URL."
        case .encodingError:
            return "Failed to encode N8N agent request."
        case .decodingError:
            return "Failed to decode N8N agent response."
        case .invalidResponse:
            return "Invalid response from N8N agent webhook."
        case .httpError(let code):
            return "N8N agent HTTP error: \(code)"
        }
    }
}