//
//  ServiceRequestDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 14..
//


struct ServiceRequestDTO: APIRequest, Codable {
    let description: String
    let severity: SeverityLevel
    let serviceId: Int64
    let address: AddressRequest
    
    enum SeverityLevel: String, Codable {
        case URGENT, HIGH, MEDIUM, LOW
    }
}
