//
//  ServiceCategoryService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

protocol ServicesServiceProtocol {
    func fetchCategories() async throws -> [ServiceCategory]
    func fetchRecommendedServices() async throws -> [ServiceProfile]
    func fetchSubcategories(categoryId: Int64) async throws -> [ServiceArea]
    func fetchServices(categoryId: Int64, subcategoryId: Int64) async throws -> [ServiceProfile]
    func fetchUserName(userId: Int64) async throws -> String
    func createServiceProfile(request: ServiceProfileRequestDTO) async throws -> ServiceProfileResponseDTO
    func createBulkServiceProfiles(request: BulkServiceProfileRequest) async throws -> [ServiceProfileResponseDTO]
}

final class ServicesService: ServicesServiceProtocol {
    private let apiClient: APIClientProtocol
    private var categories: [ServiceCategory]?
    private var recommendedServices: [ServiceProfile]?
    private var token: String?
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func createBulkServiceProfiles(request: BulkServiceProfileRequest) async throws -> [ServiceProfileResponseDTO] {
            let endpoint = Endpoint.createBulkServices(
                categoryId: request.categoryId,
                request: request
            )
            return try await apiClient.request(endpoint)
        }
    
    // Create service profile (returns ServiceProfileDTO instead of ServiceProfileRequestDTO)
    func createServiceProfile(request: ServiceProfileRequestDTO) async throws -> ServiceProfileResponseDTO {
        let endpoint = Endpoint.createServiceProfile(request: request)
        let response: ServiceProfileResponseDTO = try await apiClient.request(endpoint)
        return response
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

    func fetchSubcategories(categoryId: Int64) async throws -> [ServiceArea] {
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
