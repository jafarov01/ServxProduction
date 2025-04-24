//
//  UserSessionManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import SwiftUI
import Combine

@MainActor
final class UserSessionManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var authState: AuthState = .unknown {
        didSet {
            print("UserSessionManager: AuthState changed from \(oldValue) to \(authState)")
        }
    }
    @Published private(set) var lastAuthError: AuthError?

    // MARK: - Dependencies
    private let userService: UserServiceProtocol
    private let webSocketManager: WebSocketManager = .shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - State Management
    enum AuthState: Equatable {
        case authenticated(UserResponse)
        case unauthenticated
        case unknown

        static func == (lhs: UserSessionManager.AuthState, rhs: UserSessionManager.AuthState) -> Bool {
            switch (lhs, rhs) {
            case (.authenticated(let l), .authenticated(let r)):
                return l.id == r.id
            case (.unauthenticated, .unauthenticated):
                return true
            case (.unknown, .unknown):
                return true
            default:
                return false
            }
        }
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
        print("UserSessionManager: Checking initial auth state...")
        Task {
            do {
                if let token = try? KeychainManager.getToken(service: "auth") {
                    print("UserSessionManager: Found token, validating...")
                    try await handleToken(token)
                } else {
                    print("UserSessionManager: No initial token found.")
                    if authState != .unauthenticated {
                        updateAuthState(.unauthenticated)
                    }
                }
            } catch let error as KeychainError {
                print("UserSessionManager: Keychain error on initial check.")
                await handleError(.keychainError(error))
            } catch {
                print("UserSessionManager: Network error on initial check.")
                await handleError(.networkError(error))
            }
        }
    }

    func logout() async {
        print("UserSessionManager: Logging out...")
        do {
            try KeychainManager.deleteToken(service: "auth")
        } catch {
            print("UserSessionManager: Failed to delete token from keychain during logout: \(error)")
        }
        
        webSocketManager.disconnect(attemptReconnect: false)

        AuthenticatedUser.shared.logout()

        if authState != .unauthenticated {
            updateAuthState(.unauthenticated)
        }
    }

    // MARK: - Private Methods
    private func setupObservers() {
        AuthenticatedUser.shared.$isAuthenticated
            .dropFirst()
             .receive(on: DispatchQueue.main)
            .sink { [weak self] authenticated in
                guard let self = self else { return }
                print("UserSessionManager: Observed AuthenticatedUser.isAuthenticated change: \(authenticated)")
                if !authenticated && self.authState != .unauthenticated {
                    print("UserSessionManager: Syncing state to unauthenticated due to observer.")
                    self.updateAuthState(.unauthenticated)
                }
            }
            .store(in: &cancellables)
    }

    private func handleToken(_ token: String?) async throws {
        guard let validToken = token else {
             if authState != .unauthenticated { updateAuthState(.unauthenticated) }
            return
        }

        do {
            let userResponse = try await userService.getUserDetails()
            await validateUserDetails(userResponse, token: validToken)
        } catch {
            print("UserSessionManager: Error validating token: \(error)")
            try? KeychainManager.deleteToken(service: "auth")

            if let networkError = error as? NetworkError, case .unauthorized = networkError {
                await handleError(.unauthorized)
            } else if error is KeychainError {
                 await handleError(.keychainError(error as! KeychainError))
            }
             else {
                await handleError(.networkError(error))
            }
        }
    }

    private func validateUserDetails(_ response: UserResponse, token: String?) async {
        AuthenticatedUser.shared.authenticate(with: response)
        updateAuthState(.authenticated(response), token: token)
    }

    private func updateAuthState(_ newState: AuthState, token: String? = nil) {
        guard authState != newState else {
            print("UserSessionManager: updateAuthState called but state is already \(newState). Skipping.")
            return
        }

        print("UserSessionManager: Updating authState to \(newState)")
        withAnimation {
            authState = newState
            lastAuthError = nil
        }

        switch newState {
        case .authenticated:
            let connectToken = token ?? (try? KeychainManager.getToken(service: "auth"))
            if let validToken = connectToken {
                print("UserSessionManager: State is Authenticated, connecting WebSocket...")
                WebSocketManager.shared.connect(token: validToken)
            } else {
                print("UserSessionManager: State is Authenticated, but FAILED to get token for WebSocket.")
            }
        case .unauthenticated, .unknown:
            print("UserSessionManager: State is Unauthenticated/Unknown, disconnecting WebSocket...")
            WebSocketManager.shared.disconnect()
        }
    }

    private func handleError(_ error: AuthError) async {
         await MainActor.run {
             print("UserSessionManager: Handling error - \(error)")
             lastAuthError = error

            switch error {
            case .unauthorized, .invalidToken, .keychainError:
                if authState != .unauthenticated {
                     print("UserSessionManager: Error implies unauthenticated state. Logging out user data...")
                     AuthenticatedUser.shared.logout()
                     print("UserSessionManager: Triggering state update to unauthenticated due to error...")
                     updateAuthState(.unauthenticated)
                 }
            case .networkError:
                 print("UserSessionManager: Network error occurred, state preserved.")
            }
        }
    }
}
