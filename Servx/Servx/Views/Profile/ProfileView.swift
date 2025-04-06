//
//  BookingView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var navManager: NavigationManager
    @EnvironmentObject private var userSession: UserSessionManager
    private let authService: AuthServiceProtocol = AuthService()

    var body: some View {
        VStack {
            Text("Profile View")
                .font(.largeTitle)

            Button("Sign Out") {
                performLogout()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    
    private func performLogout() {
        // Clear local user data
        AuthenticatedUser.shared.logout()
        
        // Clear network-related data
        authService.logout()
        
        // Reset all navigation state by creating new empty paths
        navManager.mainPath = NavigationPath()
        navManager.authPath = NavigationPath()
        
        // Update authentication state
        userSession.logout()
    }
}
