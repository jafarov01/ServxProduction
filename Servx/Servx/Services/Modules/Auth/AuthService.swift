//
//  AuthService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol
    private let ongoingRequestsActor = OngoingRequestsActor()

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let idempotencyKey = UUID().uuidString
        let loginRequest = LoginRequest(email: email, password: password)

        // Check if a request with this idempotency key is already in progress
        if await ongoingRequestsActor.isRequestInProgress(for: idempotencyKey) {
            return try await ongoingRequestsActor.getExistingRequest(for: idempotencyKey)
        }

        // Create a new task for the login request
        let task = Task<AuthResponse, Error> {
            do {
                let authResponse: AuthResponse = try await apiClient.request(
                    .authLogin(body: loginRequest)
                )
                try KeychainManager.save(token: authResponse.token, service: "auth")
                return authResponse
            } catch {
                throw error
            }
        }

        // Store the task in the ongoing requests actor
        await ongoingRequestsActor.addRequest(idempotencyKey: idempotencyKey, task: task)

        do {
            let response = try await task.value
            // Remove the task from the ongoing requests actor upon completion
            await ongoingRequestsActor.removeRequest(for: idempotencyKey)
            return response
        } catch {
            // Remove the task from the ongoing requests actor in case of error
            await ongoingRequestsActor.removeRequest(for: idempotencyKey)
            throw error
        }
    }

    func register(request: RegisterRequest) async throws -> RegisterResponse {
        let task = Task<RegisterResponse, Error> {
            do {
                return try await apiClient.request(.register(body: request))
            } catch {
                throw error
            }
        }
        
        return try await task.value
    }

    func logout() {
        // Remove the token from Keychain
        try? KeychainManager.deleteToken(service: "auth")
    }
}

actor OngoingRequestsActor {
    private var ongoingRequests = [String: Task<AuthResponse, Error>]()

    func isRequestInProgress(for idempotencyKey: String) async -> Bool {
        return ongoingRequests[idempotencyKey] != nil
    }

    func addRequest(idempotencyKey: String, task: Task<AuthResponse, Error>) async {
        ongoingRequests[idempotencyKey] = task
    }

    func removeRequest(for idempotencyKey: String) async {
        ongoingRequests.removeValue(forKey: idempotencyKey)
    }

    func getExistingRequest(for idempotencyKey: String) async throws -> AuthResponse {
        guard let existingTask = ongoingRequests[idempotencyKey] else {
            throw NSError(domain: "AuthService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No ongoing request found for idempotency key"])
        }
        return try await existingTask.value
    }
}
