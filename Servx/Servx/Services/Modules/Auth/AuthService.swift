//
//  AuthService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let loginRequest = LoginRequest(email: email, password: password)

        let authResponse: AuthResponse = try await apiClient.request(
            .authLogin(body: loginRequest)
        )

        try KeychainManager.save(token: authResponse.token, service: "auth")

        return authResponse
    }

    func register(request: RegisterRequest) async throws -> RegisterResponse {
        return try await apiClient.request(.register(body: request))
    }
}
