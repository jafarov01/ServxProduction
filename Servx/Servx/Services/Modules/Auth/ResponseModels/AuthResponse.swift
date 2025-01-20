//
//  AuthResponse.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// A response model for the login API.
struct AuthResponse: Decodable {
    let token: String
    let role: String
}
