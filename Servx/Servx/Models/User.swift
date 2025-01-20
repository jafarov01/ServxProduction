//
//  User.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct User: Codable, Identifiable {
    var id: String = UUID().uuidString // Local ID initially, replaced with backend ID post-sync.
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let address: Address
    let languagesSpoken: [String]
    let role: Role
    var education: String?
    var serviceProfiles: [ServiceProfile]?
    
    enum Role: String, Codable {
        case serviceSeeker = "SERVICE_SEEKER"
        case serviceProvider = "SERVICE_PROVIDER"
    }
}
