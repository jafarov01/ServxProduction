//
//  ServiceProfile.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct ServiceProfile: Identifiable, Codable, Hashable {
    let id: Int64
    let providerId: Int64
    let providerName: String
    let categoryName: String
    let subcategoryName: String
    let workExperience: String
    let price: Double
    let rating: Double
    let reviewCount: Int
    let profilePhotoUrl: URL?

    var serviceTitle: String { "\(categoryName) - \(subcategoryName)" }

     init(id: Int64, providerId: Int64, providerName: String, categoryName: String, subcategoryName: String, workExperience: String, price: Double, rating: Double, reviewCount: Int, profilePhotoUrl: URL?) {
        self.id = id
        self.providerId = providerId
        self.providerName = providerName
        self.categoryName = categoryName
        self.subcategoryName = subcategoryName
        self.workExperience = workExperience
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.profilePhotoUrl = profilePhotoUrl
    }
}
