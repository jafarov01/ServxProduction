//
//  ServiceCategoryServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// Protocol defining the contract for fetching service categories and service areas.
protocol ServiceCategoryServiceProtocol {
    /// Fetches the list of service categories.
    /// - Returns: An array of `ServiceCategory`.
    func fetchServiceCategories() async throws -> [ServiceCategory]

    /// Fetches the list of service areas (subcategories) for a given category.
    /// - Returns: An array of `ServiceArea`.
    func fetchServiceAreas() async throws -> [ServiceArea]
}
