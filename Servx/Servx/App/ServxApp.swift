//
//  ServxApp.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import SwiftUI

@main
struct ServxApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .environment(\.colorScheme, .light)
    }
}
