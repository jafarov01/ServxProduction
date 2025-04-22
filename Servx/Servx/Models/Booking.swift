//
//  Booking.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 21..
//

import Foundation

struct Booking: Codable, Identifiable, Hashable {
    let id: Int64
    let bookingNumber: String
    let status: BookingStatus
    let scheduledStartTime: String
    let durationMinutes: Int
    let priceMin: Double
    let priceMax: Double
    let notes: String?
    let locationAddressLine: String
    let locationCity: String
    let locationZipCode: String
    let locationCountry: String
    let serviceId: Int64 // <<< Ensure this exists
    let serviceName: String
    let serviceCategoryName: String
    let providerId: Int64
    let providerFirstName: String
    let providerLastName: String
    let providerProfilePhotoUrl: URL?
    let seekerId: Int64
    let seekerFirstName: String
    let seekerLastName: String
    let seekerProfilePhotoUrl: URL?
    let serviceRequestId: Int64
    let createdAt: String?
    let updatedAt: String?

    var scheduledStartDate: Date? { ISO8601DateFormatter().date(from: scheduledStartTime) }
    var providerFullName: String { "\(providerFirstName) \(providerLastName)" }
    var seekerFullName: String { "\(seekerFirstName) \(seekerLastName)" }

    // Ensure init matches all properties including serviceId
    init(id: Int64, bookingNumber: String, status: BookingStatus, scheduledStartTime: String, durationMinutes: Int, priceMin: Double, priceMax: Double, notes: String?, locationAddressLine: String, locationCity: String, locationZipCode: String, locationCountry: String, serviceId: Int64, serviceName: String, serviceCategoryName: String, providerId: Int64, providerFirstName: String, providerLastName: String, providerProfilePhotoUrl: String?, seekerId: Int64, seekerFirstName: String, seekerLastName: String, seekerProfilePhotoUrl: String?, serviceRequestId: Int64, createdAt: String?, updatedAt: String?) {
        self.id = id
        self.bookingNumber = bookingNumber
        self.status = status
        self.scheduledStartTime = scheduledStartTime
        self.durationMinutes = durationMinutes
        self.priceMin = priceMin
        self.priceMax = priceMax
        self.notes = notes
        self.locationAddressLine = locationAddressLine
        self.locationCity = locationCity
        self.locationZipCode = locationZipCode
        self.locationCountry = locationCountry
        self.serviceId = serviceId // Assign serviceId
        self.serviceName = serviceName
        self.serviceCategoryName = serviceCategoryName
        self.providerId = providerId
        self.providerFirstName = providerFirstName
        self.providerLastName = providerLastName
        self.providerProfilePhotoUrl = URL(string: providerProfilePhotoUrl ?? "")
        self.seekerId = seekerId
        self.seekerFirstName = seekerFirstName
        self.seekerLastName = seekerLastName
        self.seekerProfilePhotoUrl = URL(string: seekerProfilePhotoUrl ?? "")
        self.serviceRequestId = serviceRequestId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum BookingStatus: String, Codable, Hashable, CaseIterable {
    case upcoming = "UPCOMING"
    case completed = "COMPLETED"
    case cancelledBySeeker = "CANCELLED_BY_SEEKER"
    case cancelledByProvider = "CANCELLED_BY_PROVIDER"

    var displayName: String {
        switch self {
        case .upcoming: return "Upcoming"
        case .completed: return "Completed"
        case .cancelledBySeeker: return "Cancelled" // Simplified display
        case .cancelledByProvider: return "Cancelled" // Simplified display
        }
    }
    
    var displayTab: DisplayTab {
        switch self {
        case .upcoming:
            return .upcoming
        case .completed:
            return .completed
        case .cancelledBySeeker, .cancelledByProvider:
            return .cancelled
        }
    }
}
