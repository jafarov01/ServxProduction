//
//  UserSessionManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class UserSessionManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var lastAuthError: AuthError?
    
    // MARK: - Dependencies
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - State Management
    enum AuthState {
        case authenticated(UserResponse)
        case unauthenticated
        case unknown
    }
    
    enum AuthError: Error, LocalizedError {
        case invalidToken
        case networkError(Error)
        case keychainError(KeychainError)
        case unauthorized
        
        var errorDescription: String? {
            switch self {
            case .invalidToken: return "Invalid session token"
            case .networkError(let error): return "Network error: \(error.localizedDescription)"
            case .keychainError(let error): return "Security error: \(error.localizedDescription)"
            case .unauthorized: return "Authentication required"
            }
        }
    }
    
    // MARK: - Initialization
    init(userService: UserServiceProtocol) {
        self.userService = userService
        setupObservers()
        checkInitialAuthState()
    }
    
    // MARK: - Public Interface
    func checkInitialAuthState() {
        Task {
            do {
                let token = try KeychainManager.getToken(service: "auth")
                try await handleToken(token)
            } catch let error as KeychainError {
                await handleError(.keychainError(error))
            } catch {
                await handleError(.networkError(error))
            }
        }
    }
    
    func logout() async {
        do {
            try KeychainManager.deleteToken(service: "auth")
            AuthenticatedUser.shared.logout()
            updateAuthState(.unauthenticated)
        } catch {
            await handleError(.keychainError(error as! KeychainError))
        }
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        AuthenticatedUser.shared.$isAuthenticated
            .dropFirst()
            .sink { [weak self] authenticated in
                if !authenticated {
                    self?.updateAuthState(.unauthenticated)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleToken(_ token: String?) async throws {
        guard let token = token else {
            return await handleError(.unauthorized)
        }
        
        do {
            let userDetails = try await userService.getUserDetails()
            await validateUserDetails(userDetails)
        } catch {
            if case KeychainError.tokenNotFound = error {
                await handleError(.unauthorized)
            } else {
                await handleError(.networkError(error))
            }
        }
    }
    
    private func validateUserDetails(_ response: UserResponse) async {
        AuthenticatedUser.shared.authenticate(with: response)
        updateAuthState(.authenticated(response))
    }
    
    private func updateAuthState(_ state: AuthState) {
        withAnimation {
            authState = state
            lastAuthError = nil
        }
    }
    
    private func handleError(_ error: AuthError) async {
        await MainActor.run {
            lastAuthError = error
            if case .unauthorized = error {
                authState = .unauthenticated
                AuthenticatedUser.shared.logout()
            }
        }
    }
}
