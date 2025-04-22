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
        case serviceCompleted = "SERVICE_COMPLETED"
        case bookingCancelled = "BOOKING_CANCELLED"
        case systemAlert = "SYSTEM_ALERT"
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
        case .serviceCompleted: return "Service Completed"
        case .systemAlert: return "System Alert"
        case .bookingCancelled: return "Booking Cancelled"
        case .requestDeclined: return "Request Declined"
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
        case .serviceCompleted:
            return "Service has been completed"
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
        // --- REMOVED: guard !notification.isRead else { return } ---
        // Allow tapping regardless of read status

        switch notification.type {
        case .newRequest, .requestDeclined: // Keep these going to detail view
            if let requestId = notification.payload.serviceRequestId {
                // Navigate using the appropriate stack if needed, or a generic navigate
                // Assuming navigate(to: AppRoute.Main...) adds to mainStack
                navigator.navigate(to: AppRoute.Main.serviceRequestDetail(id: requestId))
            }

        case .requestAccepted:
            if let requestId = notification.payload.serviceRequestId {
                 // This switches to Inbox tab and pushes chat view onto inboxStack
                navigator.navigateToChat(requestId: requestId)
            }

        case .serviceCompleted:
            if let bookingId = notification.payload.bookingId {
                // Assuming payload contains bookingId needed for review route
                navigator.navigate(to: AppRoute.Main.serviceReview(bookingId: bookingId))
            }
        case .bookingConfirmed:
             print("Routing to Booking Tab (Upcoming)")
             // Switch to the booking tab. The view's .task should load upcoming.
            navigator.switchTab(to: .booking)
             // Clear any potential sub-navigation stack on that tab

        case .bookingCancelled:
             print("Routing to Booking Tab (Cancelled)")
             // Switch to the booking tab. We'll need VM logic to default to cancelled here.
             // For now, just switch tab, user might need to select filter manually.
             // TODO: Enhance this later to pre-select the 'Cancelled' filter in BookingViewModel
            navigator.switchTab(to: .booking)

        case .systemAlert:
            // No navigation action needed
            break
        }
    }
    
}
