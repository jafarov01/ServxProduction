//
//  ServiceRequestDetailViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI
import Combine

@MainActor
final class ServiceRequestDetailViewModel: ObservableObject {
    @Published var request: ServiceRequestDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var submissionSuccess: Bool = false

    let currentUserRole: Role

    private let service: ServiceRequestServiceProtocol
    private let notificationService: NotificationServiceProtocol
    let requestId: Int64

    init(
        requestId: Int64,
        service: ServiceRequestServiceProtocol = ServiceRequestService(),
        notificationService: NotificationServiceProtocol = NotificationService()){
        self.requestId = requestId
        self.service = service
        self.notificationService = notificationService

            guard let currentUser = AuthenticatedUser.shared.currentUser else {
             fatalError("Authenticated user data is required for ServiceRequestDetailViewModel.")
        }
        self.currentUserRole = currentUser.role
        print("SRDViewModel: Initialized for requestId \(requestId), userRole: \(self.currentUserRole)")
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
        // Only provider can accept pending requests
        guard currentUserRole == .serviceProvider, request?.status == .pending else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let updatedRequest = try await service.acceptRequest(id: requestId)
            request = updatedRequest

             Task.detached {
                 try? await self.notificationService.markNotificationAsRead(notificationId: self.requestId)
             }

            submissionSuccess = true
             print("SRDViewModel: Request accepted, submissionSuccess = true")

        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }

    func isChatActiveStatus(_ status: ServiceRequest.RequestStatus?) -> Bool {
        guard let status = status else { return false }
        return status == .accepted || status == .bookingConfirmed
    }
}
