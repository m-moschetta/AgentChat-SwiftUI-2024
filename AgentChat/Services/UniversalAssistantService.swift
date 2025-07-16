//
//  UniversalAssistantService.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import Foundation

class UniversalAssistantService: ObservableObject {
    static let shared = UniversalAssistantService()
    
    private init() {}
    
    func sendMessage(
        message: String,
        provider: AssistantProvider,
        model: String,
        chatHistory: [MessageEntity] = []
    ) async throws -> String {
        
        switch provider.name {
        case "openai":
            return try await sendOpenAIMessage(message: message, model: model, provider: provider, chatHistory: chatHistory)
        case "anthropic":
            return try await sendAnthropicMessage(message: message, model: model, provider: provider, chatHistory: chatHistory)
        case "n8n":
            return try await sendN8NMessage(message: message, provider: provider)
        default:
            // Generic provider handling
            return try await sendGenericMessage(message: message, model: model, provider: provider, chatHistory: chatHistory)
        }
    }
    
    private func sendOpenAIMessage(
        message: String,
        model: String,
        provider: AssistantProvider,
        chatHistory: [MessageEntity]
    ) async throws -> String {
        
        guard let apiKey = KeychainService.shared.loadAPIKey(for: provider.name) else {
            throw AssistantError.missingAPIKey
        }
        
        var messages: [OpenAIMessage] = []
        
        // Add chat history
        for historyMessage in chatHistory {
            messages.append(OpenAIMessage(role: historyMessage.isFromUser ? "user" : "assistant", content: historyMessage.content ?? ""))
        }
        
        // Add current message
        messages.append(OpenAIMessage(role: "user", content: message))
        
        let request = OpenAIRequest(
            model: model,
            messages: messages,
            temperature: 0.7,
            maxTokens: 4000,
            stream: false
        )
        
        guard let url = URL(string: "\(provider.baseURL)/chat/completions") else {
            throw AssistantError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw AssistantError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AssistantError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AssistantError.httpError(httpResponse.statusCode)
        }
        
        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            return openAIResponse.choices.first?.message.content ?? "No response"
        } catch {
            throw AssistantError.decodingError
        }
    }
    
    private func sendAnthropicMessage(
        message: String,
        model: String,
        provider: AssistantProvider,
        chatHistory: [MessageEntity]
    ) async throws -> String {
        
        guard let apiKey = KeychainService.shared.loadAPIKey(for: provider.name) else {
            throw AssistantError.missingAPIKey
        }
        
        var messages: [AnthropicMessage] = []
        
        // Add chat history
        for historyMessage in chatHistory {
            messages.append(AnthropicMessage(role: historyMessage.isFromUser ? "user" : "assistant", content: historyMessage.content ?? ""))
        }
        
        // Add current message
        messages.append(AnthropicMessage(role: "user", content: message))
        
        let request = AnthropicRequest(
            model: model,
            maxTokens: 4000,
            messages: messages,
            temperature: 0.7
        )
        
        guard let url = URL(string: "\(provider.baseURL)/v1/messages") else {
            throw AssistantError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw AssistantError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AssistantError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AssistantError.httpError(httpResponse.statusCode)
        }
        
        do {
            let anthropicResponse = try JSONDecoder().decode(AnthropicResponse.self, from: data)
            return anthropicResponse.content.first?.text ?? "No response"
        } catch {
            throw AssistantError.decodingError
        }
    }
    
    private func sendN8NMessage(
        message: String,
        provider: AssistantProvider
    ) async throws -> String {
        
        // Use N8NService for n8n workflow handling
        return try await N8NService.shared.sendMessage(message)
    }
    
    private func sendGenericMessage(
        message: String,
        model: String,
        provider: AssistantProvider,
        chatHistory: [MessageEntity]
    ) async throws -> String {
        
        guard let apiKey = KeychainService.shared.loadAPIKey(for: provider.name) else {
            throw AssistantError.missingAPIKey
        }
        
        var messages: [GenericMessage] = []
        
        // Add chat history
        for historyMessage in chatHistory {
            messages.append(GenericMessage(role: historyMessage.isFromUser ? "user" : "assistant", content: historyMessage.content ?? ""))
        }
        
        // Add current message
        messages.append(GenericMessage(role: "user", content: message))
        
        let request = GenericRequest(
            model: model,
            messages: messages,
            temperature: 0.7,
            maxTokens: 4000
        )
        
        guard let url = URL(string: "\(provider.baseURL)/chat/completions") else {
            throw AssistantError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw AssistantError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AssistantError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AssistantError.httpError(httpResponse.statusCode)
        }
        
        do {
            let genericResponse = try JSONDecoder().decode(GenericResponse.self, from: data)
            
            // Try different response formats
            if let choices = genericResponse.choices, let firstChoice = choices.first {
                return firstChoice.message.content
            } else if let content = genericResponse.content, let firstContent = content.first {
                return firstContent.text
            } else {
                return "No response"
            }
        } catch {
            throw AssistantError.decodingError
        }
    }
}

enum AssistantError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case encodingError
    case decodingError
    case invalidResponse
    case httpError(Int)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is missing. Please configure your API key in settings."
        case .invalidURL:
            return "Invalid URL configuration."
        case .encodingError:
            return "Failed to encode request."
        case .decodingError:
            return "Failed to decode response."
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .networkError:
            return "Network error occurred."
        }
    }
}