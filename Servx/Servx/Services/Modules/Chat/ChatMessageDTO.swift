//
//  ChatMessageDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 17..
//

import Foundation

struct PageWrapper<T: Codable>: Codable {
    let content: [T]
    let page: PageInfo

    var totalPages: Int { page.totalPages }
    var totalElements: Int64 { page.totalElements }
    var size: Int { page.size }
    var number: Int { page.number }
    var first: Bool { page.first ?? (page.number == 0) }
    var last: Bool { page.last ?? (page.number >= page.totalPages - 1 && page.totalPages > 0) }
    var numberOfElements: Int { page.numberOfElements ?? content.count }
    var empty: Bool { page.empty ?? content.isEmpty }

    struct PageInfo: Codable {
        let size: Int
        let number: Int
        let totalElements: Int64
        let totalPages: Int
        let first: Bool?
        let last: Bool?
        let numberOfElements: Int?
        let empty: Bool?
    }
}


struct ChatMessageDTO: Codable, Identifiable, Hashable {
    let id: Int64
    let serviceRequestId: Int64
    let senderId: Int64
    let recipientId: Int64
    let senderName: String?
    let content: String
    let timestamp: String
    var isRead: Bool
    let bookingPayload: BookingRequestPayload?
    var bookingProposalStatus: BookingProposalState? = nil

    // Maps JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case id
        case serviceRequestId
        case senderId
        case recipientId
        case senderName
        case content
        case timestamp
        case isRead = "read"
        case bookingPayload
    }

    var identifier: Int64 { id }

    var timestampDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestamp) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: timestamp)
    }
}


struct ChatConversationDTO: Codable, Identifiable, Hashable {
    let serviceRequestId: Int64
    let otherParticipantName: String
    let otherParticipantId: Int64
    let lastMessage: String?
    let lastMessageTimestamp: String
    let unreadCount: Int
    let requestStatus: ServiceRequest.RequestStatus

    var id: Int64 { serviceRequestId }

    var lastMessageTimestampDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: lastMessageTimestamp) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: lastMessageTimestamp) ?? .distantPast
    }
}

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
    case pending // Default state when proposal is received/sent
    case accepted
    case rejected
}
