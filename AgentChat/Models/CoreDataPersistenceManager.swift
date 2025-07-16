//
//  CoreDataPersistenceManager.swift
//  AgentChat
//
//  Created by Mario Moschetta on 04/07/25.
//

import CoreData
import Foundation

class CoreDataPersistenceManager {
    static let shared = CoreDataPersistenceManager()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AgentChat")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    private init() {}
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}