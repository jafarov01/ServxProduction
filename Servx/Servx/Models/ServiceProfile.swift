//
//  ServiceProfile.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct ServiceProfile: Codable, Identifiable {
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

    private enum CodingKeys: String, CodingKey {
        case id, providerName, categoryName, subcategoryName, workExperience, price, rating, reviewCount
    }

    // Custom initializer if needed
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        providerName = try container.decode(String.self, forKey: .providerName)
        categoryName = try container.decode(String.self, forKey: .categoryName)
        subcategoryName = try container.decode(String.self, forKey: .subcategoryName)
        workExperience = try container.decode(String.self, forKey: .workExperience)
        price = try container.decode(Double.self, forKey: .price)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
    }
}
