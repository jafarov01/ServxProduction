//
//  ServiceCategoryServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

protocol ServiceCategoryServiceProtocol {
    /// Fetches the list of service categories.
    /// - Returns: An array of `ServiceCategory`.
    func fetchServiceCategories() async throws -> [ServiceCategory]

    /// Fetches the list of service areas based on a category ID.
    /// - Parameter categoryId: The ID of the selected service category.
    /// - Returns: An array of `ServiceArea` corresponding to the selected category.
    func fetchServiceAreas(forCategoryId categoryId: Int) async throws -> [ServiceArea]
}
