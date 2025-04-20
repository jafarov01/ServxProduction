//
//  ServiceRequestServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 14..
//


protocol ServiceRequestServiceProtocol {
    func submitRequest(_ request: ServiceRequestDTO) async throws -> EmptyResponseDTO
    func fetchRequestDetails(id: Int64) async throws -> ServiceRequestDetail
    func acceptRequest(id: Int64) async throws -> ServiceRequestDetail
    func confirmBooking(requestId: Int64) async throws -> ServiceRequestDetailDTO
    func rejectBooking(requestId: Int64) async throws -> ServiceRequestDetailDTO
}

class ServiceRequestService: ServiceRequestServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func submitRequest(_ request: ServiceRequestDTO) async throws -> EmptyResponseDTO {
        try await apiClient.request(.createServiceRequest(request: request))
    }
    
    func fetchRequestDetails(id: Int64) async throws -> ServiceRequestDetail {
        let endpoint = Endpoint.fetchServiceRequest(id: id)
        let dto: ServiceRequestDetailDTO = try await apiClient.request(endpoint)
        return dto.toEntity()
    }

    func acceptRequest(id: Int64) async throws -> ServiceRequestDetail {
        let endpoint = Endpoint.acceptServiceRequest(id: id)
        let dto: ServiceRequestDetailDTO = try await apiClient.request(endpoint)
        return dto.toEntity()
    }
    
    func confirmBooking(requestId: Int64) async throws -> ServiceRequestDetailDTO {
            print("ServiceRequestService: Confirming booking for request ID \(requestId)")
            let endpoint = Endpoint.confirmBooking(requestId: requestId)
            // Expect updated request DTO back from backend
            let updatedRequest: ServiceRequestDetailDTO = try await apiClient.request(endpoint)
            print("ServiceRequestService: Booking confirmed successfully.")
            return updatedRequest
        }

        func rejectBooking(requestId: Int64) async throws -> ServiceRequestDetailDTO {
            print("ServiceRequestService: Rejecting booking for request ID \(requestId)")
            let endpoint = Endpoint.rejectBooking(requestId: requestId)
            // Expect updated request DTO back from backend
            let updatedRequest: ServiceRequestDetailDTO = try await apiClient.request(endpoint)
            print("ServiceRequestService: Booking rejected successfully.")
            return updatedRequest
        }
}
