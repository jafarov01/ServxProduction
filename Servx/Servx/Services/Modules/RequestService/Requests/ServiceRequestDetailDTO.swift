//
//  ServiceRequestDetailDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import Foundation

// For receiving from backend (DTO)
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
}

// For frontend domain use
struct ServiceRequestDetail: Codable, Identifiable {
    let id: Int64
    let description: String
    let severity: ServiceRequest.SeverityLevel
    let status: ServiceRequest.RequestStatus
    let address: Address
    let createdAt: String
    let service: ServiceProfile
    let seeker: User
    let provider: User
    
    var createdAtDate: Date? {
        return createdAt.toDate()
    }
}

// For sending to backend
struct AcceptRequestDTO: Encodable, APIRequest {
    var accepted: Bool = true
    var acceptedAt: String
    
    init() {
        self.acceptedAt = Date().toString()
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // 6 digits
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension String {
    func toDate() -> Date? {
        return DateFormatter.iso8601Full.date(from: self)
    }
}

extension Date {
    func toString() -> String {
        return DateFormatter.iso8601Full.string(from: self)
    }
}

extension ServiceRequestDetailDTO {
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
