//
//  ContentView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import SwiftUI
import os

let viewLogger = Logger(subsystem: "com.servx.app", category: "viewDebug")

struct ContentView: View {
    @StateObject private var session: UserSessionManager
    @StateObject private var navigator: NavigationManager
    
    init() {
        let userService = UserService()
        let session = UserSessionManager(userService: userService)
        let navigator = NavigationManager(userSession: session)
        
        _session = StateObject(wrappedValue: session)
        _navigator = StateObject(wrappedValue: navigator)
    }
    
    var body: some View {
        Group {
            if navigator.isSplashVisible {
                SplashScreenView()
                    .task { navigator.setupInitialNavigation() }
            } else {
                authStateView
            }
        }
        .environmentObject(session)
        .environmentObject(navigator)
    }
    
    @ViewBuilder
    private var authStateView: some View {
        switch session.authState {
        case .authenticated:
            MainTabView()
        case .unauthenticated:
            UnauthenticatedFlowView()
        case .unknown:
            Button("Reset App State") {
                Task {
                    // Clear all persistent data
                    try? KeychainManager.deleteToken(service: "auth")
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                    UserDefaults.standard.synchronize()
                    
                    // Reset app state
                    await session.logout()
                    navigator.resetAllStacks()
                    
                    // Restart app state
                    await MainActor.run {
                        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                            .windows.first?.rootViewController = UIHostingController(rootView: ContentView())
                    }
                }
            }
        }
    }
}
