//
//  ServiceRequestDetailViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI

@MainActor
final class ServiceRequestDetailViewModel: ObservableObject {
    @Published var request: ServiceRequestDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var submissionSuccess: Bool = false
    
    private let service: ServiceRequestServiceProtocol
    private let notificationService: NotificationServiceProtocol
    let requestId: Int64
    
    init(
        requestId: Int64,
        service: ServiceRequestServiceProtocol = ServiceRequestService(),
        notificationService: NotificationServiceProtocol = NotificationService()
    ) {
        self.requestId = requestId
        self.service = service
        self.notificationService = notificationService
    }
    
    func loadRequestDetails() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            request = try await service.fetchRequestDetails(id: requestId)
        } catch {
            handleError(error)
        }
    }
    
    func acceptRequest() async {
        guard request?.status == .pending else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Update backend
            let updatedRequest = try await service.acceptRequest(id: requestId)
            
            // Update local state
            request = updatedRequest
            
            // Mark notification as read
            try await notificationService.markNotificationAsRead(notificationId: requestId)
            
            // Navigate to chat
            await MainActor.run {
                submissionSuccess = true
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
