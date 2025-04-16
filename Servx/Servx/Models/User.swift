//
//  User.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int64
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let address: Address
    let languagesSpoken: [String]
    let role: Role
    var profilePhotoUrl: URL?
    let education: String?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    // Optional computed property for cleaner access
    var formattedEducation: String? {
        guard role == .serviceProvider else { return nil }
        return education
    }
}

enum Role: String, Codable {
    case serviceSeeker = "SERVICE_SEEKER"
    case serviceProvider = "SERVICE_PROVIDER"
}
