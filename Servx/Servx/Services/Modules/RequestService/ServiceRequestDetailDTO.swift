//
//  ServiceRequestDetailDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import Foundation

struct ServiceRequestDetailDTO: Decodable {
    let id: Int64
    let description: String
    let severity: ServiceRequest.SeverityLevel
    let status: ServiceRequest.RequestStatus
    let address: AddressResponse
    let createdAt: String
    let service: ServiceProfileResponseDTO
    let seeker: UserResponse
    let provider: UserResponse
    
    func toEntity() -> ServiceRequestDetail {
        ServiceRequestDetail(
            id: id,
            description: description,
            severity: severity,
            status: status,
            address: address.toEntity(),
            createdAt: createdAt,
            service: service.toEntity(),
            seeker: seeker.toEntity(),
            provider: provider.toEntity()
        )
    }
}

struct ServiceRequestDTO: APIRequest, Codable {
    let description: String
    let severity: SeverityLevel
    let serviceId: Int64
    let address: AddressRequest
    
    enum SeverityLevel: String, Codable {
        case URGENT, HIGH, MEDIUM, LOW
    }
}

struct AcceptRequestDTO: Encodable, APIRequest {
    var accepted: Bool = true
    var acceptedAt: String
    
    init() {
        self.acceptedAt = Date().toString()
    }
}
