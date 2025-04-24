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
        
        let createdNotification: Notification = try await apiClient.request(
            .createNotification(notification)
        )
        return createdNotification
    }
    
    func fetchNotifications() async throws -> [Notification] {
        let notifications: [Notification] = try await apiClient.request(
            .getNotifications
        )
        return notifications
    }
    
    func markNotificationAsRead(notificationId: Int64) async throws {
        let _: EmptyResponseDTO = try await apiClient.request(
            .markNotificationAsRead(notificationId: notificationId)
        )
    }
}
