//
//  ServiceProfile.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct ServiceProfile: Codable, Identifiable {
    let id: String
    let userId: String? // Optional to align with the backend (not sent during registration)
    let serviceCategoryId: String
    let serviceAreaIds: [String]
    let workExperience: String
    
    func toDictionary() -> [String: Any] {
        [
            "serviceCategoryId": serviceCategoryId,
            "serviceAreaIds": serviceAreaIds,
            "workExperience": workExperience
        ]
    }
}
