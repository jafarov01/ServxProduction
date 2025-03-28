//
//  HomeService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

final class HomeService: HomeServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchServiceCategories() async throws -> [ServiceCategory] {
        let endpoint = Endpoint.serviceCategories
        return try await apiClient.request(endpoint)
    }
}
