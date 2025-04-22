//
//  ServiceProfileResponseDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 12..
//

struct ServiceProfileResponseDTO: Decodable, Identifiable {
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
            profilePhotoUrl: profilePhotoUrl 
        )
    }
}
