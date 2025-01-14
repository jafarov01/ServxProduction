//
//  AuthServices.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 03..
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, NetworkError>
}

class AuthService: AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, NetworkError> {
        let endpoint = Endpoint(
            path: "https://api.servx.com/auth/login",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: ["email": email, "password": password]
        )

        return APIManager.shared.request(endpoint: endpoint, responseType: AuthResponse.self)
    }
}
