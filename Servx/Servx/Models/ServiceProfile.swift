//
//  ServiceProfile.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct ServiceProfile: Codable, Identifiable, Equatable, Hashable {
    let id: Int64
    let providerName: String
    let categoryName: String
    let subcategoryName: String
    let workExperience: String
    let price: Double
    let rating: Double
    let reviewCount: Int

    // Additional derived fields
    var serviceTitle: String {
        return "\(categoryName) - \(subcategoryName)"
    }
}
