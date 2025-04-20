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
    @Published var submissionSuccess: Bool = false // Still used for initial navigation post-accept

    // --- NEW: Add current user role ---
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

        // --- Set current user role ---
            guard let currentUser = AuthenticatedUser.shared.currentUser else {
             // Handle error case - perhaps shouldn't happen if view requires auth
             fatalError("Authenticated user data is required for ServiceRequestDetailViewModel.")
        }
        self.currentUserRole = currentUser.role
        print("SRDViewModel: Initialized for requestId \(requestId), userRole: \(self.currentUserRole)")
    }

    func loadRequestDetails() async {
        // No changes needed here
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
            request = updatedRequest // Update local state first

             // Attempt to mark as read (best effort)
             // Using task detachment as it's not critical for main flow
             Task.detached {
                 try? await self.notificationService.markNotificationAsRead(notificationId: self.requestId)
             }

            // Set flag to trigger initial navigation via .onChange in View
            submissionSuccess = true
             print("SRDViewModel: Request accepted, submissionSuccess = true")

        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        // No changes needed here
        errorMessage = error.localizedDescription
        showError = true
    }

    // --- Helper to check if chat should be accessible ---
    // Based on the backend ChatService logic
    func isChatActiveStatus(_ status: ServiceRequest.RequestStatus?) -> Bool {
        guard let status = status else { return false }
        return status == .accepted || status == .bookingConfirmed
        // Add other relevant statuses if chat persists longer
    }
}
