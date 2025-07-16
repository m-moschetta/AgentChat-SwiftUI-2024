//
//  ChatDetailView.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import SwiftUI
import CoreData

struct ChatDetailView: View {
    let chat: ChatEntity
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var assistantService = UniversalAssistantService.shared
    
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @FetchRequest private var messages: FetchedResults<MessageEntity>
    
    init(chat: ChatEntity) {
        self.chat = chat
        self._messages = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \MessageEntity.createdAt, ascending: true)],
            predicate: NSPredicate(format: "chat == %@", chat),
            animation: .default
        )
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            HStack {
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...5)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle(chat.title ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // Create user message
        let userMessage = MessageEntity(context: viewContext)
        userMessage.id = UUID()
        userMessage.content = trimmedMessage
        userMessage.isFromUser = true
        userMessage.createdAt = Date()
        userMessage.chat = chat
        
        // Clear input and set loading state
        messageText = ""
        isLoading = true
        
        // Save user message
        do {
            try viewContext.save()
        } catch {
            alertMessage = "Failed to save message: \(error.localizedDescription)"
            showingAlert = true
            isLoading = false
            return
        }
        
        // Send to assistant
        Task {
            do {
                let response = try await assistantService.sendMessage(
                    trimmedMessage,
                    provider: chat.providerName ?? "",
                    model: chat.modelName ?? ""
                )
                
                await MainActor.run {
                    // Create assistant message
                    let assistantMessage = MessageEntity(context: viewContext)
                    assistantMessage.id = UUID()
                    assistantMessage.content = response
                    assistantMessage.isFromUser = false
                    assistantMessage.createdAt = Date()
                    assistantMessage.chat = chat
                    
                    // Update chat
                    chat.lastMessage = response
                    chat.updatedAt = Date()
                    
                    do {
                        try viewContext.save()
                    } catch {
                        alertMessage = "Failed to save response: \(error.localizedDescription)"
                        showingAlert = true
                    }
                    
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to get response: \(error.localizedDescription)"
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

struct MessageBubbleView: View {
    let message: MessageEntity
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content ?? "")
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Text(message.createdAt ?? Date(), style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content ?? "")
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Text(message.createdAt ?? Date(), style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    let context = CoreDataPersistenceManager.shared.container.viewContext
    let chat = ChatEntity(context: context)
    chat.id = UUID()
    chat.title = "Preview Chat"
    chat.providerName = "OpenAI"
    chat.modelName = "gpt-4"
    chat.createdAt = Date()
    
    return ChatDetailView(chat: chat)
        .environment(\.managedObjectContext, context)
}