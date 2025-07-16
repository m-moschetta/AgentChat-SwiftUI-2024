//
//  SettingsView.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var configuration = LocalAssistantConfiguration.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("API Keys") {
                    ForEach(AssistantProvider.allCases, id: \.self) { provider in
                        NavigationLink(destination: ProviderSettingsView(provider: provider)) {
                            HStack {
                                Image(systemName: provider.iconName)
                                    .foregroundColor(provider.color)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading) {
                                    Text(provider.displayName)
                                        .font(.headline)
                                    Text(provider.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if configuration.isProviderConfigured(provider) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("GitHub Repository", destination: URL(string: "https://github.com/m-moschetta/AgentChat-SwiftUI-2024")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProviderSettingsView: View {
    let provider: AssistantProvider
    
    @StateObject private var configuration = LocalAssistantConfiguration.shared
    @State private var apiKey = ""
    @State private var baseURL = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text(provider.displayName), footer: Text(provider.description)) {
                SecureField("API Key", text: $apiKey)
                    .textContentType(.password)
                
                if provider.supportsCustomBaseURL {
                    TextField("Base URL (optional)", text: $baseURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            
            Section("Available Models") {
                ForEach(provider.models, id: \.self) { model in
                    Text(model)
                }
            }
            
            Section {
                Button("Save Configuration") {
                    saveConfiguration()
                }
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                if configuration.isProviderConfigured(provider) {
                    Button("Remove Configuration", role: .destructive) {
                        removeConfiguration()
                    }
                }
            }
        }
        .navigationTitle(provider.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadConfiguration()
        }
        .alert("Configuration", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadConfiguration() {
        apiKey = configuration.getAPIKey(for: provider) ?? ""
        baseURL = configuration.getBaseURL(for: provider) ?? ""
    }
    
    private func saveConfiguration() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKey.isEmpty else {
            alertMessage = "API Key cannot be empty"
            showingAlert = true
            return
        }
        
        do {
            try configuration.setAPIKey(trimmedKey, for: provider)
            
            if !trimmedURL.isEmpty {
                try configuration.setBaseURL(trimmedURL, for: provider)
            }
            
            alertMessage = "Configuration saved successfully"
            showingAlert = true
        } catch {
            alertMessage = "Failed to save configuration: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func removeConfiguration() {
        do {
            try configuration.removeAPIKey(for: provider)
            try configuration.removeBaseURL(for: provider)
            
            apiKey = ""
            baseURL = ""
            
            alertMessage = "Configuration removed successfully"
            showingAlert = true
        } catch {
            alertMessage = "Failed to remove configuration: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    SettingsView()
}