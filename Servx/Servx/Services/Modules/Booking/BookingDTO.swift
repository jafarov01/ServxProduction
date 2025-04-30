//
//  BookingDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 30..
//

import Foundation

struct BookingRequestPayload: Codable, Hashable {
    let agreedDateTime: String
    let serviceRequestDetailsText: String
    let priceMin: Double?
    let priceMax: Double?
    let notes: String?
    let durationMinutes: Int?

    var agreedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: agreedDateTime) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: agreedDateTime)
    }
}

enum BookingProposalState: String, Codable, Hashable {
    case pending
    case accepted
    case rejected
}

struct BookingDTO: Codable, Identifiable {
    let id: Int64
    let bookingNumber: String
    let status: BookingStatus
    let providerMarkedComplete: Bool?
    let scheduledStartTime: String
    let durationMinutes: Int
    let priceMin: Double
    let priceMax: Double
    let notes: String?
    let locationAddressLine: String
    let locationCity: String
    let locationZipCode: String
    let locationCountry: String
    let serviceId: Int64 // <<< ADDED
    let serviceName: String
    let serviceCategoryName: String
    let providerId: Int64
    let providerFirstName: String
    let providerLastName: String
    let providerProfilePhotoUrl: String?
    let seekerId: Int64
    let seekerFirstName: String
    let seekerLastName: String
    let seekerProfilePhotoUrl: String?
    let serviceRequestId: Int64
    let createdAt: String?
    let updatedAt: String?

    func toEntity() -> Booking {
        return Booking(
            id: id, bookingNumber: bookingNumber, status: status,
            scheduledStartTime: scheduledStartTime,
            durationMinutes: durationMinutes, priceMin: priceMin, priceMax: priceMax,
            notes: notes, locationAddressLine: locationAddressLine, locationCity: locationCity,
            locationZipCode: locationZipCode, locationCountry: locationCountry,
            serviceId: serviceId, // Pass serviceId
            serviceName: serviceName, serviceCategoryName: serviceCategoryName,
            providerId: providerId, providerFirstName: providerFirstName, providerLastName: providerLastName,
            providerProfilePhotoUrl: providerProfilePhotoUrl,
            seekerId: seekerId, seekerFirstName: seekerFirstName, seekerLastName: seekerLastName,
            seekerProfilePhotoUrl: seekerProfilePhotoUrl,
            serviceRequestId: serviceRequestId,
            createdAt: createdAt, updatedAt: updatedAt,
            providerMarkedComplete: providerMarkedComplete ?? false
        )
    }
}
