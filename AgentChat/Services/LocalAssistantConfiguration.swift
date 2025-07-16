//
//  LocalAssistantConfiguration.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import Foundation

class LocalAssistantConfiguration: ObservableObject {
    static let shared = LocalAssistantConfiguration()
    
    @Published var providers: [AssistantProvider] = []
    @Published var customProviders: [AssistantProvider] = []
    
    private let userDefaults = UserDefaults.standard
    private let providersKey = "assistant_providers"
    private let customProvidersKey = "custom_providers"
    
    private init() {
        loadConfiguration()
    }
    
    func loadConfiguration() {
        // Load default providers
        providers = AssistantProvider.defaultProviders
        
        // Load custom providers
        if let data = userDefaults.data(forKey: customProvidersKey),
           let decoded = try? JSONDecoder().decode([AssistantProvider].self, from: data) {
            customProviders = decoded
        }
    }
    
    func saveConfiguration() {
        // Save custom providers
        if let encoded = try? JSONEncoder().encode(customProviders) {
            userDefaults.set(encoded, forKey: customProvidersKey)
        }
    }
    
    func addCustomProvider(_ provider: AssistantProvider) {
        customProviders.append(provider)
        saveConfiguration()
    }
    
    func removeCustomProvider(at index: Int) {
        guard index < customProviders.count else { return }
        customProviders.remove(at: index)
        saveConfiguration()
    }
    
    func getAllProviders() -> [AssistantProvider] {
        return providers + customProviders
    }
    
    func getProvider(by name: String) -> AssistantProvider? {
        return getAllProviders().first { $0.name == name }
    }
    
    func isProviderConfigured(_ provider: AssistantProvider) -> Bool {
        if !provider.requiresAPIKey {
            return true
        }
        
        let apiKey = KeychainService.shared.loadAPIKey(for: provider.name)
        return apiKey != nil && !apiKey!.isEmpty
    }
    
    func getConfiguredProviders() -> [AssistantProvider] {
        return getAllProviders().filter { isProviderConfigured($0) && $0.isActive }
    }
}