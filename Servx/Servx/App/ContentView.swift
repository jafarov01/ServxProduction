//
//  ContentView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userSessionManager = UserSessionManager(
        userDetailsService: UserService()
    )
    
    @StateObject private var navigationManager = NavigationManager(
        userSessionManager: UserSessionManager(
            userDetailsService: UserService()
        )
    )

    var body: some View {
        Group {
            if navigationManager.isSplashVisible {
                SplashScreenView()
                    .onAppear {
                        navigationManager.setupInitialNavigation()
                    }
            } else if !navigationManager.isAuthenticated {
                UnauthenticatedFlowView()
            } else {
                MainTabView()
            }
        }
        .environmentObject(navigationManager)
        .environmentObject(userSessionManager)
    }
}
