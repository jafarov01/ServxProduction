//
//  ServiceRequestDetail.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 30..
//

import Foundation

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
