//
//  AuthResponse.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 03..
//

struct AuthResponse: Decodable {
    let token: String
    let userRole: String
}
