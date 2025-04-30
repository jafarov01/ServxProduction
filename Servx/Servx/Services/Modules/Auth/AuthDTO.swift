//
//  LoginRequest.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

struct LoginRequest: APIRequest {
    let email: String
    let password: String
}

struct ForgotPasswordRequest: APIRequest {
    let email: String
}

struct RefreshTokenRequest: APIRequest {
    let token: String
}

struct AuthResponse: Decodable {
    let token: String
    let role: String
}

struct RegisterResponse: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let languagesSpoken: [String]
    let address: AddressResponse
    let role: String
    let profilePhotoUrl: String

    /// Nested structure for address in the response.
    struct AddressResponse: Decodable {
        let city: String
        let country: String
        let zipCode: String
        let addressLine: String
    }
}

struct RegisterRequest: APIRequest {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phoneNumber: String
    let role: String
    let address: AddressRequest
    let languagesSpoken: [String]
}

struct AddressRequest: APIRequest {
    let city: String
    let country: String
    let zipCode: String
    let addressLine: String
}
