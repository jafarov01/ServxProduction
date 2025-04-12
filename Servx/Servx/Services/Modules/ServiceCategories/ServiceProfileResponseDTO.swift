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
    
    // Initialization from backend ServiceProfileDTO response
    init(service: ServiceProfile) {
        self.id = service.id
        self.providerName = service.providerName
        self.categoryName = service.categoryName
        self.subcategoryName = service.subcategoryName
        self.workExperience = service.workExperience
        self.price = service.price
        self.rating = service.rating
        self.reviewCount = service.reviewCount
    }
}
