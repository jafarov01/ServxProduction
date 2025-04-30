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
    func fetchServiceProfile(id: Int64) async throws -> ServiceProfile
    func searchServices(query: String) async throws -> [ServiceProfile]
}

final class ServicesService: ServicesServiceProtocol {
    private let apiClient: APIClientProtocol
    private var categories: [ServiceCategory]?
    private var recommendedServices: [ServiceProfile]?
    private var token: String?
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchServiceProfile(id: Int64) async throws -> ServiceProfile {
        print("ServicesService: Fetching service profile ID: \(id)")
        let endpoint = Endpoint.fetchServiceProfile(profileId: id)
        let dto: ServiceProfileResponseDTO = try await apiClient.request(endpoint)
        print("ServicesService: Fetched service profile successfully.")
        return dto.toEntity()
    }
    
    func createBulkServiceProfiles(request: BulkServiceProfileRequest) async throws -> [ServiceProfileResponseDTO] {
        print("\n===== ServicesService =====")
        print("🚀 Starting Bulk Service Profile Creation")
        
        let endpoint = Endpoint.createBulkServices(
            categoryId: request.categoryId,
            request: request
        )
        
        let response: [ServiceProfileResponseDTO] = try await apiClient.request(endpoint)
        print("🎉 Bulk Service Creation Successful (\(response.count) services created)")
        return response
    }
    
    func searchServices(query: String) async throws -> [ServiceProfile] {
        print("ServicesService: Searching services with query: \(query)")
        let endpoint = Endpoint.searchServices(query: query)

        let _: [ServiceProfileResponseDTO] = try await apiClient.request(endpoint)

        let results: [ServiceProfileResponseDTO] = try await apiClient.request(endpoint)

        print("ServicesService: Found \(results.count) services.")
        return results.map { $0.toEntity() }
    }
    
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
        let endpoint = Endpoint.fetchRecommendedServices
        let recommendedServicesResponse: [ServiceProfileResponseDTO] = try await apiClient.request(endpoint)
        return recommendedServicesResponse.map { $0.toEntity() }
    }

    func fetchSubcategories(categoryId: Int64) async throws -> [ServiceArea] {
        print("\n===== ServicesService =====")
        print("🔍 Fetching Subcategories for Category ID: \(categoryId)")
        let endpoint = Endpoint.fetchSubcategories(categoryId: categoryId)
        return try await withLoggedErrorHandling(endpoint: endpoint)
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
    
    private func withLoggedErrorHandling<T: Decodable>(endpoint: Endpoint) async throws -> T {
        do {
            return try await apiClient.request(endpoint)
        } catch {
            print("🚨 API Error for \(endpoint.url): \(error.localizedDescription)")
            throw error
        }
    }
}
