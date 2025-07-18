//
//  AgentChatApp.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import SwiftUI
import CoreData

@main
struct AgentChatApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let persistenceController = CoreDataPersistenceManager.shared

    var body: some Scene {
        WindowGroup {
            ChatListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.saveContext()
        }
    }
}