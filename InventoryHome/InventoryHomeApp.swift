//
//  InventoryHomeApp.swift
//  InventoryHome
//
//  Created by Ehtisham Khalid on 28.07.2024.
//

import SwiftUI

@main
struct InventoryHomeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
