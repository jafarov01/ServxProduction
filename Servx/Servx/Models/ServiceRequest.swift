//
//  ServiceRequest.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 14..
//

import Foundation

struct ServiceRequest: Codable, Identifiable {
    let id: Int64?
    let description: String
    let status: RequestStatus
    let severity: SeverityLevel
    let seekerId: Int64
    let providerId: Int64
    let serviceId: Int64
    let address: Address
    let createdAt: Date
    
    enum RequestStatus: String, Codable {
        case pending = "PENDING"
        case accepted = "ACCEPTED"
        case declined = "DECLINED"
        case completed = "COMPLETED"
        case bookingConfirmed = "BOOKING_CONFIRMED"
    }
    
    enum SeverityLevel: String, Codable, CaseIterable {
        case urgent = "URGENT"
        case high = "HIGH"
        case medium = "MEDIUM"
        case low = "LOW"
    }
}
