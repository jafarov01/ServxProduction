//
//  ServiceProfileRequestDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 12..
//

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
