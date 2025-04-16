//
//  ServiceRequestServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 14..
//


protocol ServiceRequestServiceProtocol {
    func submitRequest(_ request: ServiceRequestDTO) async throws -> EmptyResponseDTO
}

class ServiceRequestService: ServiceRequestServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func submitRequest(_ request: ServiceRequestDTO) async throws -> EmptyResponseDTO {
        try await apiClient.request(.createServiceRequest(request: request))
    }
}
