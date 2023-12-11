//
//  lab1_3App.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import SwiftUI

@main
struct lab1_3App: App {
    var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
