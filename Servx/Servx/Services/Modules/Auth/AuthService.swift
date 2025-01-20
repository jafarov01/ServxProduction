//
//  AuthService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// Implementation of the AuthServiceProtocol for making authentication-related API calls.
final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol

    /// Dependency Injection
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Login method for authenticating a user.
    /// - Parameters:
    ///   - email: The email of the user.
    ///   - password: The password of the user.
    /// - Returns: An `AuthResponse` containing the token and role.
    func login(email: String, password: String) async throws -> AuthResponse {
        // Prepare the login request
        let loginRequest = LoginRequest(email: email, password: password)

        // Make API call using APIClient
        let authResponse: AuthResponse = try await apiClient.request(
            .authLogin(body: loginRequest)
        )

        // Save the token and role using UserDefaultsManager
        UserDefaultsManager.authToken = authResponse.token
        UserDefaultsManager.userRole = authResponse.role

        return authResponse
    }

    /// Register method for service seekers.
    /// - Parameters:
    ///   - seekerRequest: The registration details for a service seeker.
    /// - Returns: A response model containing user details.
    func registerServiceSeeker(seekerRequest: RegisterSeekerRequest) async throws -> RegisterResponse {
        // Make API call using APIClient
        return try await apiClient.request(
            .registerSeeker(body: seekerRequest)
        )
    }

    /// Register method for service providers.
    /// - Parameters:
    ///   - providerRequest: The registration details for a service provider.
    /// - Returns: A response model containing user details.
    func registerServiceProvider(providerRequest: RegisterProviderRequest) async throws -> RegisterResponse {
        // Make API call using APIClient
        return try await apiClient.request(
            .registerProvider(body: providerRequest)
        )
    }
}
