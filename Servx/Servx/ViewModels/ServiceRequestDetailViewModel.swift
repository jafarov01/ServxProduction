//
//  ServiceRequestDetailViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI

@MainActor
class ServiceRequestDetailViewModel: ObservableObject {
    @Published var request: ServiceRequestResponseDTO?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let service: ServiceRequestServiceProtocol
    private let requestId: Int64
    private let notificationService: NotificationServiceProtocol
    
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
            request = try await service.fetchServiceRequest(id: requestId)
        } catch {
            handleError(error)
        }
    }
    
    func acceptRequest() async {
        guard let request = request else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await service.acceptServiceRequest(id: requestId)
            try await notificationService.createNotification(
                recipientId: request.seeker.id,
                type: .requestAccepted,
                payload: NotificationPayload(
                    serviceRequestId: requestId,
                    message: "Your request was accepted"
                )
            )
            // Update local state
            self.request?.status = .accepted
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
