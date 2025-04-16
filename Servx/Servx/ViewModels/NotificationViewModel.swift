//
//  NotificationViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI
import Combine

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var isLoading = false
    @Published var showError = false
    var errorMessage = ""
    
    private let service: NotificationServiceProtocol
    
    init(service: NotificationServiceProtocol = NotificationService()) {
        self.service = service
    }
    
    func loadNotifications() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            notifications = try await service.fetchNotifications()
        } catch {
            handleError(error)
        }
    }
    
    func markAsRead(_ notificationId: Int64) async {
        do {
            try await service.markNotificationAsRead(notificationId: notificationId)
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                notifications[index].isRead = true
            }
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

enum NotificationError: LocalizedError {
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .unauthorized: return "You need to login first"
        }
    }
}
