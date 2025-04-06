//
//  UserSessionManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import Foundation
import Combine

@MainActor
final class UserSessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var hasFetchedUserData = false
    private let userDetailsService: UserDetailsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(userDetailsService: UserDetailsServiceProtocol) {
        self.userDetailsService = userDetailsService
        setupAuthObservers()
        checkAuthenticationStatus()
    }

    private func setupAuthObservers() {
        $isAuthenticated
            .removeDuplicates()
            .sink { [weak self] authenticated in
                guard let self else { return }
                if !authenticated {
                    self.cleanupSession()
                }
            }
            .store(in: &cancellables)
    }

    private func checkAuthenticationStatus() {
        Task {
            do {
                if let token = try KeychainManager.getToken(service: "auth") {
                    await handleValidToken(token)
                } else {
                    handleMissingToken()
                }
            } catch {
                await handleAuthError(error)
            }
        }
    }

    private func handleValidToken(_ token: String) async {
        if !isAuthenticated {
            do {
                let userDetails = try await userDetailsService.getUserDetails()
                AuthenticatedUser.shared.authenticateUser(from: userDetails)
                await MainActor.run {
                    isAuthenticated = true
                    hasFetchedUserData = true
                }
            } catch {
                await handleAuthError(error)
            }
        } else {
            await MainActor.run {
                hasFetchedUserData = true
            }
        }
    }

    private func handleMissingToken() {
        isAuthenticated = false
        hasFetchedUserData = false
    }

    private func handleAuthError(_ error: Error) async {
        await MainActor.run {
            isAuthenticated = false
            hasFetchedUserData = false
        }
        print("Auth error: \(error.localizedDescription)")
    }

    private func cleanupSession() {
        AuthenticatedUser.shared.logout()
        hasFetchedUserData = false
    }

    func logout() {
        do {
            try KeychainManager.deleteToken(service: "auth")
            isAuthenticated = false
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}
