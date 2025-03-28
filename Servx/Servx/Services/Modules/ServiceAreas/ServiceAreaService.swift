//
//  ServiceAreaService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

final class ServiceAreaService: ServiceAreaServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchServices(for areaId: Int64) async throws -> [ServiceProfile] {
        let endpoint = Endpoint.serviceAreaProfiles(areaId: areaId)
        let response: [ServiceProfile] = try await apiClient.request(endpoint)
        return response
    }
}
