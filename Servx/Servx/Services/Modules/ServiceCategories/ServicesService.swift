//
//  ServiceCategoryService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

final class ServicesService: ServicesServiceProtocol {
    private let apiClient: APIClientProtocol
    private var categories: [ServiceCategory]?
    private var recommendedServices: [ServiceProfile]?
    private var token: String?
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchCategories() async throws -> [ServiceCategory] {
        if let cachedCategories = categories {
            return cachedCategories
        }
        
        let endpoint = Endpoint.fetchCategories
        let categoriesResponse: [ServiceCategory] = try await apiClient.request(endpoint)
        self.categories = categoriesResponse
        return categoriesResponse
    }

    func fetchRecommendedServices() async throws -> [ServiceProfile] {
        if let cachedServices = recommendedServices {
            return cachedServices
        }
        
        let endpoint = Endpoint.fetchRecommendedServices
        let recommendedServicesResponse: [ServiceProfile] = try await apiClient.request(endpoint)
        self.recommendedServices = recommendedServicesResponse
        return recommendedServicesResponse
    }

    func fetchSubcategories(categoryId: Int64) async throws -> [Subcategory] {
        let endpoint = Endpoint.fetchSubcategories(categoryId: categoryId)
        return try await apiClient.request(endpoint)
    }

    func fetchServices(categoryId: Int64, subcategoryId: Int64) async throws -> [ServiceProfile] {
        let endpoint = Endpoint.fetchServices(categoryId: categoryId, subcategoryId: subcategoryId)
        return try await apiClient.request(endpoint)
    }

    func fetchUserName(userId: Int64) async throws -> String {
        let endpoint = Endpoint.fetchUserDetails(userId: userId)
        let user: User = try await apiClient.request(endpoint)
        return user.firstName
    }
}
