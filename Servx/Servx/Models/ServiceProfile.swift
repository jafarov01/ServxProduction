//
//  ServiceProfile.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct Review: Codable, Identifiable {
    let id: String
    let userId: String
    let rating: Double
    let comment: String
    let createdAt: Date
}

struct ServiceProfile: Codable, Identifiable {
    let id: String
    let userId: Int64?
    let serviceCategoryId: String
    let serviceAreaIds: [String]
    let workExperience: String
    let reviews: [Review]
    let rating: Double
    let reviewCount: Int
    let price: Double

    var serviceTitle: String
    var providerName: String?

    private enum CodingKeys: String, CodingKey {
        case id, userId, serviceCategoryId, serviceAreaIds, workExperience,
            reviews, price
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decodeIfPresent(Int64.self, forKey: .userId)
        serviceCategoryId = try container.decode(
            String.self, forKey: .serviceCategoryId)
        serviceAreaIds = try container.decode(
            [String].self, forKey: .serviceAreaIds)
        workExperience = try container.decode(
            String.self, forKey: .workExperience)
        reviews = try container.decode([Review].self, forKey: .reviews)
        price = try container.decode(Double.self, forKey: .price)

        // Compute derived values
        rating = reviews.map { $0.rating }.average
        reviewCount = reviews.count
        serviceTitle = "Unknown Service"
    }
}

extension Array where Element == Double {
    var average: Double {
        return isEmpty ? 0 : reduce(0, +) / Double(count)
    }
}
