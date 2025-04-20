//
//  InboxViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 17..
//

import SwiftUI
import Combine

@MainActor // Ensures UI updates happen on the main thread
class InboxViewModel: ObservableObject {

    @Published var conversations: [ChatConversationDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedRequestId: Int64? = nil // Tracks which chat to navigate to

    private let chatService: ChatServiceProtocol
    // TODO: Inject WebSocketManager later

    init(chatService: ChatServiceProtocol = ChatService()) {
        self.chatService = chatService
    }

    // Fetches conversations from the backend
    func loadConversations() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        selectedRequestId = nil // Reset selection on reload

        do {
            conversations = try await chatService.fetchConversations()
        } catch {
            // --- Check if the error is the specific "cancelled" error ---
            let nsError = error as NSError
            if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                // --- If it's NOT a cancellation error, THEN show it ---
                self.errorMessage = error.localizedDescription // Set error message for UI
                print("InboxViewModel: Error loading conversations: \(error)")
            } else {
                // --- If it IS a cancellation error, just log it quietly ---
                 print("InboxViewModel: Conversation load cancelled (likely due to navigation).")
            }
            // -------------------------------------------------------------
        }
        isLoading = false
    }

    // Called by the View when a conversation row is tapped
    func selectConversation(requestId: Int64) {
        selectedRequestId = requestId // Triggers .onChange in the View
    }

    // Placeholder for WebSocket updates
    func handleNewMessage(_ message: ChatMessageDTO) {
        Task { await loadConversations() } // Simple reload for now
    }
}
