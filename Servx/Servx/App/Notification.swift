//
//  Notification.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//


import Foundation
import SwiftUI

// MARK: - Notification Model
struct Notification: Identifiable, Codable, APIRequest {
    let id: Int64
    let type: NotificationType
    let createdAt: String
    var isRead: Bool
    let payload: NotificationPayload
    
    // MARK: - Notification Type
    enum NotificationType: String, Codable {
        case newRequest = "NEW_REQUEST"
        case requestAccepted = "REQUEST_ACCEPTED"
        case requestDeclined = "REQUEST_DECLINED"
        case bookingConfirmed = "BOOKING_CONFIRMED"
        case bookingCancelled = "BOOKING_CANCELLED"
        case systemAlert = "SYSTEM_ALERT"
        case providerMarkedComplete = "PROVIDER_MARKED_COMPLETE"
        case seekerConfirmedCompletion = "SEEKER_CONFIRMED_COMPLETION"
    }
    
    struct NotificationPayload: Codable {
        var serviceRequestId: Int64?
        var bookingId: Int64?
        var message: String?
        var userId: Int64?
        
        
        enum CodingKeys: String, CodingKey {
            case serviceRequestId, bookingId, message, userId
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case createdAt
        case isRead = "read"
        case payload
    }
}

// MARK: - Notification Utilities
extension Notification {
    func formattedDate() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = dateFormatter.date(from: createdAt) else {
            return "Invalid Date"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
    
    func formattedTitle() -> String {
        switch type {
        case .newRequest: return "New Service Request"
        case .requestAccepted: return "Request Accepted"
        case .bookingConfirmed: return "Booking Confirmed"
        case .systemAlert: return "System Alert"
        case .bookingCancelled: return "Booking Cancelled"
        case .requestDeclined: return "Request Declined"
        case .providerMarkedComplete: return "Provider Marked Complete"
        case .seekerConfirmedCompletion: return "Seeker Confirmed Completion"
        }
    }
    
    func formattedMessage() -> String {
        switch type {
        case .newRequest:
            return "You have a new service request"
        case .bookingConfirmed:
            return "Your booking has been confirmed"
        case .systemAlert:
            return payload.message ?? "System notification"
        case .requestAccepted:
            return "Your service request was accepted"
        case .requestDeclined:
            return "Your service request was declined"
        case .bookingCancelled:
            return "Your booking has been cancelled"
        case .providerMarkedComplete:
            return "Your service has been completed"
        case .seekerConfirmedCompletion:
            return "Your service has been completed"
        }
    }
}

// MARK: - Navigation Handler Protocol
protocol NotificationRouterProtocol {
    @MainActor
    func handleNavigation(for notification: Notification, navigator: NavigationManager)
}

struct NotificationRouter: NotificationRouterProtocol {
    @MainActor
    func handleNavigation(for notification: Notification, navigator: NavigationManager) {

        switch notification.type {
        case .providerMarkedComplete, .seekerConfirmedCompletion:
            if notification.payload.bookingId != nil {
                navigator.switchTab(to: .booking)
            }
        
        case .newRequest, .requestDeclined:
            if let requestId = notification.payload.serviceRequestId {
                navigator.navigate(to: AppRoute.Main.serviceRequestDetail(id: requestId))
            }

        case .requestAccepted:
            if let requestId = notification.payload.serviceRequestId {
                navigator.navigateToChat(requestId: requestId)
            }

        case .bookingConfirmed:
             print("Routing to Booking Tab (Upcoming)")
            navigator.switchTab(to: .booking)

        case .bookingCancelled:
             print("Routing to Booking Tab (Cancelled)")
            navigator.switchTab(to: .booking)

        case .systemAlert:
            break
        }
    }
    
}
