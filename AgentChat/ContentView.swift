//
//  ContentView.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ChatListView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, CoreDataPersistenceManager.shared.container.viewContext)
}