//
//  UserDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//


import Foundation

// MARK: - User and Address Data Transfer Objects
struct UserResponse: Decodable {
    let id: Int64
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let address: AddressResponse
    let languagesSpoken: [String]
    let role: RoleResponse
    let education: String?
    let profilePhotoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, firstName, lastName,
             phoneNumber, address,
             languagesSpoken, role,
             education, profilePhotoUrl
    }
    
    func toEntity() -> User {
         return User(
             id: id,
             email: email,
             firstName: firstName,
             lastName: lastName,
             phoneNumber: phoneNumber,
             address: address.toEntity(),
             languagesSpoken: languagesSpoken,
             role: role.toEntity(),
             education: education,
             profilePhotoUrl: profilePhotoUrl
         )
     }
}
struct AddressResponse: Decodable {
    let addressLine: String
    let city: String
    let zipCode: String
    let country: String
}

enum RoleResponse: String, Decodable {
    case serviceSeeker = "SERVICE_SEEKER"
    case serviceProvider = "SERVICE_PROVIDER"
}

// MARK: - Profile Photo Response DTO
struct ProfilePhotoResponse: Decodable {
    let url: String
    
    func fullURL() -> URL? {
        let baseURL = URL(string: "http://localhost:8080")!
        return URL(string: url, relativeTo: baseURL)
    }
}

// MARK: - Delete Photo Response DTO
struct DeletePhotoResponse: Decodable {
    let success: Bool
    let message: String?
}

struct EmptyResponseDTO: Decodable { }

extension AddressResponse {
    func toEntity() -> Address {
        Address(
            addressLine: addressLine,
            city: city,
            zipCode: zipCode,
            country: country
        )
    }
}

extension RoleResponse {
    func toEntity() -> Role {
        Role(rawValue: self.rawValue) ?? .serviceSeeker
    }
}
