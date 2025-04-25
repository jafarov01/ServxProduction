//
//  AuthService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthResponse
    func register(request: RegisterRequest) async throws -> RegisterResponse
    func logout()
    func requestPasswordReset(email: String) async throws
}

final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol
    private let ongoingRequestsActor = OngoingRequestsActor()

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let idempotencyKey = UUID().uuidString
        let loginRequest = LoginRequest(email: email, password: password)

        if await ongoingRequestsActor.isRequestInProgress(for: idempotencyKey) {
            return try await ongoingRequestsActor.getExistingRequest(for: idempotencyKey)
        }

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

        await ongoingRequestsActor.addRequest(idempotencyKey: idempotencyKey, task: task)

        do {
            let response = try await task.value
            await ongoingRequestsActor.removeRequest(for: idempotencyKey)
            return response
        } catch {
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
        try? KeychainManager.deleteToken(service: "auth")
    }
    
    func requestPasswordReset(email: String) async throws {
        print("AuthService: Requesting password reset for email: \(email)")
        let requestBody = ForgotPasswordRequest(email: email)
        let endpoint = Endpoint.forgotPassword(body: requestBody)

        let _: EmptyResponseDTO = try await apiClient.request(endpoint)

        print("AuthService: Password reset request sent successfully (API call succeeded)")
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
