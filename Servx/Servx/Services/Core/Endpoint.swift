//
//  Endpoint.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// Defines all API endpoints in a centralized manner
enum Endpoint {
    case authLogin(body: LoginRequest)
    case register(body: RegisterRequest)

    var url: String {
        let baseURL = "http://localhost:8080/api/"
        switch self {
        case .authLogin:
            return "\(baseURL)auth/login"
        case .register:
            return "\(baseURL)auth/register"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .authLogin, .register:
            return .post
        }
    }

    var body: Encodable? {
        switch self {
        case .authLogin(let body):
            return body
        case .register(let body):
            return body
        }
    }
}
