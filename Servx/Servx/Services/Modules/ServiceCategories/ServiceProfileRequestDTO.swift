//
//  ServiceProfileRequestDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 12..
//

import Foundation

struct ServiceProfileResponseDTO: Codable, Identifiable {
    let id: Int64
    let providerId: Int64
    let providerName: String
    let categoryName: String
    let subcategoryName: String
    let workExperience: String?
    let price: Double
    let rating: Double?
    let reviewCount: Int?
    let profilePhotoUrl: String?

    func toEntity() -> ServiceProfile {
        return ServiceProfile(
            id: id,
            providerId: providerId,
            providerName: providerName,
            categoryName: categoryName,
            subcategoryName: subcategoryName,
            workExperience: workExperience ?? "",
            price: price,
            rating: rating ?? 0.0,
            reviewCount: reviewCount ?? 0,
            profilePhotoUrl: URL(string: profilePhotoUrl ?? "")
        )
    }
}

struct ServiceProfileRequestDTO: Encodable, APIRequest {
    let categoryId: Int64
    let serviceAreaId: Int64
    let workExperience: String
    let price: Double
}

struct BulkServiceProfileRequest: Encodable, APIRequest{
    let categoryId: Int64
    let serviceAreaIds: [Int64]
    let workExperience: String
    let price: Double
}
