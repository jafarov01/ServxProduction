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
        // Optional: Use didSet to clearly see state transitions if needed for debugging
        didSet {
            print("UserSessionManager: AuthState changed from \(oldValue) to \(authState)")
        }
    }
    @Published private(set) var lastAuthError: AuthError?

    // MARK: - Dependencies
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - State Management
    enum AuthState: Equatable { // Make Equatable for easier comparison
        case authenticated(UserResponse)
        case unauthenticated
        case unknown

        // Need to implement Equatable manually if UserResponse isn't Equatable
        static func == (lhs: UserSessionManager.AuthState, rhs: UserSessionManager.AuthState) -> Bool {
            switch (lhs, rhs) {
            case (.authenticated(let l), .authenticated(let r)):
                return l.id == r.id // Compare based on user ID or relevant data
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
                    // handleToken now might trigger state changes via handleError
                    try await handleToken(token)
                } else {
                    print("UserSessionManager: No initial token found.")
                    // Ensure state becomes unauthenticated if not already
                    if authState != .unauthenticated {
                        updateAuthState(.unauthenticated) // Trigger disconnect explicitly
                    }
                }
            } catch let error as KeychainError {
                print("UserSessionManager: Keychain error on initial check.")
                await handleError(.keychainError(error)) // Let handleError manage state
            } catch {
                print("UserSessionManager: Network error on initial check.")
                await handleError(.networkError(error)) // Let handleError manage state
            }
        }
    }

    func logout() async {
        print("UserSessionManager: Logging out...")
        // 1. Clear token first (best effort)
        do {
            try KeychainManager.deleteToken(service: "auth")
        } catch {
            // Log the error but continue logout process
            print("UserSessionManager: Failed to delete token from keychain during logout: \(error)")
            // Optionally report this error differently?
        }

        // 2. Log out the shared user instance
        AuthenticatedUser.shared.logout() // This might trigger the sink observer, careful planning needed

        // 3. Update state to trigger disconnect and UI changes
        // Ensure this doesn't conflict if sink observer also calls it
        if authState != .unauthenticated {
            updateAuthState(.unauthenticated)
        }
    }

    // MARK: - Private Methods
    private func setupObservers() {
        // This observer reacts if AuthenticatedUser changes *externally* or via logout()
        AuthenticatedUser.shared.$isAuthenticated
            .dropFirst() // Ignore initial value
             .receive(on: DispatchQueue.main) // Ensure runs on main thread
            .sink { [weak self] authenticated in
                guard let self = self else { return }
                print("UserSessionManager: Observed AuthenticatedUser.isAuthenticated change: \(authenticated)")
                // If user becomes unauthenticated, ensure our state matches and WS disconnects
                if !authenticated && self.authState != .unauthenticated {
                    print("UserSessionManager: Syncing state to unauthenticated due to observer.")
                    self.updateAuthState(.unauthenticated) // Trigger disconnect via state change
                }
                 // If user becomes authenticated *externally*, should we try to connect WS?
                 // Probably not, connect should happen via login/token validation flow.
            }
            .store(in: &cancellables)
    }

    private func handleToken(_ token: String?) async throws {
        guard let validToken = token else {
            // If no token, ensure state is unauthenticated
             if authState != .unauthenticated { updateAuthState(.unauthenticated) }
            return // No need to throw, just exit
        }

        do {
            let userResponse = try await userService.getUserDetails() // Assumes APIClient uses token
            // Pass token for connect logic within updateAuthState
            await validateUserDetails(userResponse, token: validToken)
        } catch {
            print("UserSessionManager: Error validating token: \(error)")
             // Try deleting the invalid token regardless of error type
            try? KeychainManager.deleteToken(service: "auth")

            // Determine the appropriate AuthError and let handleError manage state
            if let networkError = error as? NetworkError, case .unauthorized = networkError {
                await handleError(.unauthorized)
            } else if error is KeychainError {
                 await handleError(.keychainError(error as! KeychainError)) // Safe if type checked
            }
             else {
                await handleError(.networkError(error))
            }
             // Rethrow if needed by caller? checkInitialAuthState doesn't need it.
             // throw error // Optional: depends if caller needs to know about failure beyond state change
        }
    }

    private func validateUserDetails(_ response: UserResponse, token: String?) async {
        // Update shared user state
        AuthenticatedUser.shared.authenticate(with: response)
        // Update local auth state and trigger WebSocket connect
        // Pass token explicitly if available, otherwise updateAuthState will try keychain
        updateAuthState(.authenticated(response), token: token)
    }

    // Central point for state changes AND side effects (like WS connect/disconnect)
    private func updateAuthState(_ newState: AuthState, token: String? = nil) {
        // Prevent redundant updates and potential infinite loops
        guard authState != newState else {
            print("UserSessionManager: updateAuthState called but state is already \(newState). Skipping.")
            return
        }

        print("UserSessionManager: Updating authState to \(newState)")
        withAnimation { // Animate UI changes if any
            authState = newState
            lastAuthError = nil // Clear error on successful state change
        }

        // Perform side effects based on the NEW state
        switch newState {
        case .authenticated:
            // Try to get token (prefer passed-in token, fallback to keychain)
            let connectToken = token ?? (try? KeychainManager.getToken(service: "auth"))
            if let validToken = connectToken {
                print("UserSessionManager: State is Authenticated, connecting WebSocket...")
                WebSocketManager.shared.connect(token: validToken)
            } else {
                // This case should ideally not happen if login/token handling is correct
                print("UserSessionManager: State is Authenticated, but FAILED to get token for WebSocket.")
                // Maybe schedule a retry? For now, just log.
            }
        case .unauthenticated, .unknown:
            // Disconnect WebSocket if entering these states
            print("UserSessionManager: State is Unauthenticated/Unknown, disconnecting WebSocket...")
            WebSocketManager.shared.disconnect()
        }
    }

    // Handles errors, logs them, and triggers state changes via updateAuthState
    private func handleError(_ error: AuthError) async {
        // Ensure runs on main thread for UI updates
         await MainActor.run {
             print("UserSessionManager: Handling error - \(error)")
             lastAuthError = error

             // Decide if state needs changing based on error type
            switch error {
            case .unauthorized, .invalidToken, .keychainError:
                // These errors mean we are effectively unauthenticated
                if authState != .unauthenticated {
                     print("UserSessionManager: Error implies unauthenticated state. Logging out user data...")
                     AuthenticatedUser.shared.logout() // Log out shared user state first
                     print("UserSessionManager: Triggering state update to unauthenticated due to error...")
                     updateAuthState(.unauthenticated) // Update state, which triggers WS disconnect
                 }
            case .networkError:
                // Network errors don't necessarily mean logged out, just log it.
                // UI can display lastAuthError. State remains unchanged.
                 print("UserSessionManager: Network error occurred, state preserved.")
            }
        }
    }
}
