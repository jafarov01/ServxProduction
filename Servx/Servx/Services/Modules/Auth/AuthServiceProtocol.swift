//
//  AuthServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

protocol AuthServiceProtocol {
    /// Login method for authenticating a user.
    /// - Parameters:
    ///   - email: The email of the user.
    ///   - password: The password of the user.
    /// - Returns: An `AuthResponse` containing the token and role.
    func login(email: String, password: String) async throws -> AuthResponse

    /// Register method for service seekers.
    /// - Parameters:
    ///   - seekerRequest: The registration details for a service seeker.
    /// - Returns: A response model containing user details.
    func registerServiceSeeker(seekerRequest: RegisterSeekerRequest) async throws -> RegisterResponse

    /// Register method for service providers.
    /// - Parameters:
    ///   - providerRequest: The registration details for a service provider.
    /// - Returns: A response model containing user details.
    func registerServiceProvider(providerRequest: RegisterProviderRequest) async throws -> RegisterResponse
}