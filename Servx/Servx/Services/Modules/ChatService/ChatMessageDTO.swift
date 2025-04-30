//
//  ChatMessageDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 17..
//

import Foundation

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
    let otherParticipantPhotoUrl: URL?

    // Keep id computed property
    var id: Int64 { serviceRequestId }

    // Keep date computed property
    var lastMessageTimestampDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: lastMessageTimestamp) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: lastMessageTimestamp) ?? .distantPast
    }

    // Custom Decodable Initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all standard properties
        serviceRequestId = try container.decode(Int64.self, forKey: .serviceRequestId)
        otherParticipantName = try container.decode(String.self, forKey: .otherParticipantName)
        otherParticipantId = try container.decode(Int64.self, forKey: .otherParticipantId)
        lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        lastMessageTimestamp = try container.decode(String.self, forKey: .lastMessageTimestamp)
        unreadCount = try container.decode(Int.self, forKey: .unreadCount)
        requestStatus = try container.decode(ServiceRequest.RequestStatus.self, forKey: .requestStatus)
        
        // Decode the photo path string
        let photoPath = try container.decodeIfPresent(String.self, forKey: .otherParticipantPhotoUrl)
        
        self.otherParticipantPhotoUrl = URL(string: photoPath ?? "")
    }

     // Add a simple memberwise initializer if needed for testing or other manual creation
     init(serviceRequestId: Int64, otherParticipantName: String, otherParticipantId: Int64, lastMessage: String?, lastMessageTimestamp: String, unreadCount: Int, requestStatus: ServiceRequest.RequestStatus, otherParticipantPhotoUrl: URL?) {
         self.serviceRequestId = serviceRequestId
         self.otherParticipantName = otherParticipantName
         self.otherParticipantId = otherParticipantId
         self.lastMessage = lastMessage
         self.lastMessageTimestamp = lastMessageTimestamp
         self.unreadCount = unreadCount
         self.requestStatus = requestStatus
         self.otherParticipantPhotoUrl = otherParticipantPhotoUrl
     }
}


