//
//  ServiceCategoryService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

final class ServiceCategoryService: ServiceCategoryServiceProtocol {
    private let apiClient: APIClientProtocol

    /// Dependency Injection
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    /// Fetches the list of service categories.
    /// - Returns: An array of `ServiceCategory`.
    func fetchServiceCategories() async throws -> [ServiceCategory] {
        let categoriesResponse: [ServiceCategory] = try await apiClient.request(Endpoint.serviceCategories)
        return categoriesResponse
    }

    /// Fetches the list of service areas for a specific category.
    /// - Parameter categoryId: The ID of the selected service category.
    /// - Returns: An array of `ServiceArea`.
    func fetchServiceAreas(forCategoryId categoryId: Int) async throws -> [ServiceArea] {
        let areasResponse: [ServiceArea] = try await apiClient.request(Endpoint.serviceAreas(categoryId: categoryId))
        return areasResponse
    }
}
