//
//  NotificationServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import Foundation

protocol NotificationServiceProtocol {
    func createNotification(type: Notification.NotificationType, payload: Notification.NotificationPayload) async throws -> Notification
    func fetchNotifications() async throws -> [Notification]
    func markNotificationAsRead(notificationId: Int64) async throws
}

class NotificationService: NotificationServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // Create a generalized notification
    func createNotification(type: Notification.NotificationType, payload: Notification.NotificationPayload) async throws -> Notification {
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        
        let notification = Notification(
            id: 0,
            type: type,
            createdAt: dateFormatter.string(from: Date()),
            isRead: false,
            payload: payload
        )
        
        // Explicitly specify the return type for the request
        let createdNotification: Notification = try await apiClient.request(
            .createNotification(notification)
        )
        return createdNotification
    }
    
    // Fetch notifications for a user
    func fetchNotifications() async throws -> [Notification] {
        // Explicitly specify the generic return type
        let notifications: [Notification] = try await apiClient.request(
            .getNotifications
        )
        return notifications
    }
    
    // Mark notification as read
    func markNotificationAsRead(notificationId: Int64) async throws {
        // Specify Void return type for empty responses
        let _: EmptyResponseDTO = try await apiClient.request(
            .markNotificationAsRead(notificationId: notificationId)
        )
    }
}
