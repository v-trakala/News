//
//  NewsApp.swift
//  News
//
//  Created by valery.trakala on 16/08/2026.
//

import SwiftUI
import CoreData

@main
struct NewsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
