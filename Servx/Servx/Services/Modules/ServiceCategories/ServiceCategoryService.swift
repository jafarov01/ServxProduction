//
//  ServiceCategoryService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// Implementation of the `ServiceCategoryServiceProtocol` for fetching service categories and service areas.
final class ServiceCategoryService: ServiceCategoryServiceProtocol {
    private let apiClient: APIClientProtocol

    /// Dependency Injection
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Fetches the list of service categories.
    /// - Returns: An array of `ServiceCategory`.
    func fetchServiceCategories() async throws -> [ServiceCategory] {
        // Make the API call using APIClient
        let categoriesResponse: ServiceCategoriesResponse = try await apiClient.request(Endpoint.serviceCategories)
        // Return the categories directly
        return categoriesResponse.categories
    }

    /// Fetches the list of service areas..
    /// - Returns: An array of `ServiceArea`.
    func fetchServiceAreas() async throws -> [ServiceArea] {
        // Make the API call using APIClient
        let areasResponse: ServiceAreasResponse = try await apiClient.request(Endpoint.serviceAreas)
        // Return the subcategories directly
        return areasResponse.areas
    }
}
