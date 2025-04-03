//
//  UserDetailsResponse.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

struct UserDetailsResponse: Codable {
    let id: Int64
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let profilePhotoUrl: String?
    let role: String
    let address: Address
    let languagesSpoken: [String]
    
    struct Address: Codable {
        let city: String
        let country: String
        let zipCode: String
        let addressLine: String
    }
}
