//
//  AssistantProvider.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import Foundation

struct AssistantProvider: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let baseURL: String
    let models: [String]
    let requiresAPIKey: Bool
    let isCustom: Bool
    let isActive: Bool
    
    init(name: String, displayName: String, baseURL: String, models: [String], requiresAPIKey: Bool = true, isCustom: Bool = false, isActive: Bool = true) {
        self.name = name
        self.displayName = displayName
        self.baseURL = baseURL
        self.models = models
        self.requiresAPIKey = requiresAPIKey
        self.isCustom = isCustom
        self.isActive = isActive
    }
    
    static let defaultProviders: [AssistantProvider] = [
        AssistantProvider(
            name: "openai",
            displayName: "OpenAI",
            baseURL: "https://api.openai.com/v1",
            models: [
                "gpt-4o",
                "gpt-4o-2024-05-13",
                "gpt-4.1",
                "gpt-4.1-mini",
                "gpt-4-turbo",
                "gpt-4-turbo-vision-preview",
                "gpt-3.5-turbo"
            ]
        ),
        AssistantProvider(
            name: "anthropic",
            displayName: "Anthropic",
            baseURL: "https://api.anthropic.com",
            models: [
                "claude-opus-4-20250514",
                "claude-sonnet-4-20250514",
                "claude-3.5-sonnet-20240620",
                "claude-3-5-haiku-20241022",
                "claude-3-7-sonnet-20250219",
                "claude-3-opus-20240229",
                "claude-3-sonnet-20240229",
                "claude-3-haiku-20240307"
            ]
        ),
        AssistantProvider(
            name: "perplexity",
            displayName: "Perplexity",
            baseURL: "https://api.perplexity.ai",
            models: [
                "sonar-pro",
                "llama-3.1-sonar-huge-128k-online",
                "llama-3.1-sonar-large-32k-online",
                "sonar-reasoning-pro",
                "sonar-deep-research",
                "llama-3.1-405b-instruct",
                "llama-3.1-70b-instruct",
                "mixtral-8x7b-instruct"
            ]
        ),
        AssistantProvider(
            name: "mistral",
            displayName: "Mistral AI",
            baseURL: "https://api.mistral.ai/v1",
            models: [
                "mistral-large-latest",
                "mistral-small-latest",
                "mistral-large-2411",
                "devstral-medium",
                "magistral-small-2506",
                "pixtral-large-2411",
                "voxtral-small-2507",
                "open-mistral-7b",
                "open-mixtral-8x7b",
                "open-mixtral-8x22b"
            ]
        ),
        AssistantProvider(
            name: "xai",
            displayName: "XAI (Grok)",
            baseURL: "https://api.x.ai/v1",
            models: [
                "grok-4",
                "grok-4-0709",
                "grok-1.5",
                "grok-1.5-vision"
            ]
        ),
        AssistantProvider(
            name: "n8n",
            displayName: "n8n Workflow",
            baseURL: "",
            models: ["workflow"],
            requiresAPIKey: false,
            isCustom: false
        )
    ]
}