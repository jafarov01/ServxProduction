//
//  LoginRequest.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// A model for the login request payload.
struct LoginRequest: Encodable {
    let email: String
    let password: String
}
