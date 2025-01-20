//
//  ServiceProfile.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct ServiceProfile: Codable, Identifiable {
    var id: String = UUID().uuidString // Local ID, replaced post-sync.
    let serviceCategoryId: String // References the ID of a ServiceCategory.
    let serviceAreaIds: [String] // IDs of ServiceAreas (subcategories).
    let workExperience: String
    
    func toDictionary() -> [String: Any] {
            [
                "id": id,
                "serviceCategoryId": serviceCategoryId,
                "serviceAreaIds": serviceAreaIds,
                "workExperience": workExperience
            ]
        }
}
