//
//  UserSessionManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import SwiftUI

@MainActor
final class UserSessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var hasFetchedUserData = false // Flag to ensure user data is fetched only once per session
    private let userDetailsService: UserDetailsServiceProtocol

    init(userDetailsService: UserDetailsServiceProtocol) {
        self.userDetailsService = userDetailsService
        self.checkAuthenticationStatus()
    }

    // Check if user is authenticated by looking for token in Keychain
    private func checkAuthenticationStatus() {
        Task {
            if let token = try? KeychainManager.getToken(service: "auth") {
                // If token exists, authenticate the user and fetch user details
                await self.authenticateUserAndFetchDetails(token: token)
            } else {
                self.isAuthenticated = false
            }
        }
    }

    // Authenticate user and fetch user data if token is valid
    private func authenticateUserAndFetchDetails(token: String) async {
        // Authenticate the user based on the token
        if !self.isAuthenticated {
            // Make the API call to fetch user details
            do {
                let userDetails = try await userDetailsService.getUserDetails()
                // Populate AuthenticatedUser singleton with fetched data
                AuthenticatedUser.shared.authenticateUser(from: userDetails)
                self.isAuthenticated = true
                self.hasFetchedUserData = true
            } catch {
                // Handle error and update UI state
                self.isAuthenticated = false
                print("Failed to load user details: \(error.localizedDescription)")
            }
        } else {
            // If the user is already authenticated, mark the data as fetched
            self.hasFetchedUserData = true
        }
    }

    // Optional: Logout functionality
    func logout() {
        AuthenticatedUser.shared.logout()
        self.isAuthenticated = false
        self.hasFetchedUserData = false
    }
}
