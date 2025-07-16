//
//  ChatListView.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import SwiftUI
import CoreData

struct ChatListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ChatEntity.createdAt, ascending: false)],
        animation: .default)
    private var chats: FetchedResults<ChatEntity>
    
    @State private var showingNewChat = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(chats) { chat in
                    NavigationLink(destination: ChatDetailView(chat: chat)) {
                        ChatRowView(chat: chat)
                    }
                }
                .onDelete(perform: deleteChats)
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gear")
                        }
                        Button(action: { showingNewChat = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewChat) {
                NewChatView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            
            // Default view when no chat is selected
            Text("Select a chat to start")
                .foregroundColor(.secondary)
        }
    }
    
    private func deleteChats(offsets: IndexSet) {
        withAnimation {
            offsets.map { chats[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Handle the error appropriately
                print("Error deleting chat: \(error)")
            }
        }
    }
}

struct ChatRowView: View {
    let chat: ChatEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(chat.title ?? "New Chat")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(chat.createdAt ?? Date(), style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(chat.providerName ?? "Unknown")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Text(chat.modelName ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            if let lastMessage = chat.lastMessage {
                Text(lastMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ChatListView()
        .environment(\.managedObjectContext, CoreDataPersistenceManager.shared.container.viewContext)
}