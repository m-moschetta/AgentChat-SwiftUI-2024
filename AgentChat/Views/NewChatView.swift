//
//  NewChatView.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import SwiftUI
import CoreData

struct NewChatView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var configuration = LocalAssistantConfiguration.shared
    
    @State private var selectedProvider: AssistantProvider?
    @State private var selectedModel: String = ""
    @State private var chatTitle: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Chat Details") {
                    TextField("Chat Title (optional)", text: $chatTitle)
                }
                
                Section("Provider") {
                    Picker("Select Provider", selection: $selectedProvider) {
                        Text("Select a provider").tag(nil as AssistantProvider?)
                        ForEach(configuration.getConfiguredProviders(), id: \.id) { provider in
                            Text(provider.displayName).tag(provider as AssistantProvider?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                if let provider = selectedProvider {
                    Section("Model") {
                        Picker("Select Model", selection: $selectedModel) {
                            Text("Select a model").tag("")
                            ForEach(provider.models, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createChat()
                    }
                    .disabled(selectedProvider == nil || selectedModel.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func createChat() {
        guard let provider = selectedProvider else {
            alertMessage = "Please select a provider"
            showingAlert = true
            return
        }
        
        guard !selectedModel.isEmpty else {
            alertMessage = "Please select a model"
            showingAlert = true
            return
        }
        
        let newChat = ChatEntity(context: viewContext)
        newChat.id = UUID()
        newChat.title = chatTitle.isEmpty ? "New Chat with \(provider.displayName)" : chatTitle
        newChat.providerName = provider.name
        newChat.modelName = selectedModel
        newChat.createdAt = Date()
        newChat.updatedAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to create chat: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    NewChatView()
        .environment(\.managedObjectContext, CoreDataPersistenceManager.shared.container.viewContext)
}