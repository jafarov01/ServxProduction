//
//  SupportRequestDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 22..
//


struct SupportRequestDTO: Encodable, APIRequest {
    let message: String
}

protocol SupportServiceProtocol {
    func sendSupportRequest(message: String) async throws
}

// Concrete implementation of the SupportService
class SupportService: SupportServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func sendSupportRequest(message: String) async throws {
        print("SupportService: Sending support request...")
        let requestDTO = SupportRequestDTO(message: message)
        let endpoint = Endpoint.sendSupportRequest(body: requestDTO)
        let _: EmptyResponseDTO = try await apiClient.request(endpoint)
        print("SupportService: Support request sent successfully.")
    }
}
