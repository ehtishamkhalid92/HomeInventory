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
    
    init() {
           requestNotificationPermissions()
       }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
}
