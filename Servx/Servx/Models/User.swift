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
    
    init(id: Int64, email: String, firstName: String, lastName: String, phoneNumber: String, address: Address, languagesSpoken: [String], role: Role, education: String?, profilePhotoUrl: String?) {
             self.id = id
             self.email = email
             self.firstName = firstName
             self.lastName = lastName
             self.phoneNumber = phoneNumber
             self.address = address
             self.languagesSpoken = languagesSpoken
             self.role = role
             self.education = education
             self.profilePhotoUrl = URL(string: profilePhotoUrl ?? "")
         }
}

enum Role: String, Codable {
    case serviceSeeker = "SERVICE_SEEKER"
    case serviceProvider = "SERVICE_PROVIDER"
}
