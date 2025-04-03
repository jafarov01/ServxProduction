//
//  UserDetailsProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 01..
//

protocol UserDetailsServiceProtocol {
    func getUserDetails() async throws -> UserDetailsResponse
}
