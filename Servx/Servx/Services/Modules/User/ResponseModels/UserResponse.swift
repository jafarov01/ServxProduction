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
    let profilePhotoUrl: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, email, firstName, lastName,
             phoneNumber, address,
             languagesSpoken, role,
             profilePhotoUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode primitive values
        id = try container.decode(Int64.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        address = try container.decode(AddressResponse.self, forKey: .address)
        languagesSpoken = try container.decode([String].self, forKey: .languagesSpoken)
        role = try container.decode(RoleResponse.self, forKey: .role)
        
        // Handle profile photo URL construction
        let baseURL = URL(string: "http://localhost:8080")!
        let photoPath = try container.decode(String.self, forKey: .profilePhotoUrl)
        profilePhotoUrl = URL(string: photoPath, relativeTo: baseURL)!
        
        print("Constructed profile URL: \(profilePhotoUrl?.absoluteString ?? "nil")")
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

extension UserResponse {
    func toEntity() -> User {
        User(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            address: address.toEntity(),
            languagesSpoken: languagesSpoken,
            role: role.toEntity(),
            profilePhotoUrl: profilePhotoUrl
        )
    }
}
