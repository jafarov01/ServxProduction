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
    let profilePhotoUrl: String?
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
}

// MARK: - Delete Photo Response DTO
struct DeletePhotoResponse: Decodable {
    let success: Bool
    let message: String?
}
