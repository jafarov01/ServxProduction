//
//  ServiceProfileResponseDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 12..
//

struct ServiceProfileResponseDTO: Decodable {
    let id: Int64
    let providerName: String
    let categoryName: String
    let subcategoryName: String
    let workExperience: String
    let price: Double
    let rating: Double
    let reviewCount: Int
}

extension ServiceProfileResponseDTO {
    func toEntity() -> ServiceProfile {
        ServiceProfile(
            id: id,
            providerName: providerName,
            categoryName: categoryName,
            subcategoryName: subcategoryName,
            workExperience: workExperience,
            price: price,
            rating: rating,
            reviewCount: reviewCount
        )
    }
}
