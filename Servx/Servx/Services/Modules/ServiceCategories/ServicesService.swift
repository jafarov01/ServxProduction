//
//  ServiceCategoryService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

final class ServicesService: ServicesServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchCategories() async throws -> [ServiceCategory] {
        let endpoint = Endpoint.fetchCategories
        return try await apiClient.request(endpoint)
    }

    func fetchRecommendedServices() async throws -> [ServiceProfile] {
        let endpoint = Endpoint.fetchRecommendedServices
        return try await apiClient.request(endpoint)
    }

    func fetchSubcategories(categoryId: Int64) async throws -> [Subcategory] {
        let endpoint = Endpoint.fetchSubcategories(categoryId: categoryId)
        return try await apiClient.request(endpoint)
    }

    func fetchServices(categoryId: Int64, subcategoryId: Int64) async throws
        -> [ServiceProfile]
    {
        let endpoint = Endpoint.fetchServices(
            categoryId: categoryId, subcategoryId: subcategoryId)
        return try await apiClient.request(endpoint)
    }

    func fetchUserName(userId: Int64) async throws -> String {
        let endpoint = Endpoint.fetchUserDetails(userId: userId)
        let user: User = try await apiClient.request(endpoint)
        return user.firstName
    }
}
