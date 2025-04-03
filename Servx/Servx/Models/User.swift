//
//  User.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let address: Address
    let languagesSpoken: [String]
    let role: Role
    let profilePhotoUrl: String?
    
    enum Role: String, Codable {
        case serviceSeeker = "SERVICE_SEEKER"
        case serviceProvider = "SERVICE_PROVIDER"
    }
}
