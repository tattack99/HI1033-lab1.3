//
//  lab1_3App.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import SwiftUI

@main
struct lab1_3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
