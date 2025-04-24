//
//  InboxViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 17..
//

import SwiftUI
import Combine

@MainActor
class InboxViewModel: ObservableObject {

    @Published var conversations: [ChatConversationDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedRequestId: Int64? = nil

    private let chatService: ChatServiceProtocol

    init(chatService: ChatServiceProtocol = ChatService()) {
        self.chatService = chatService
    }

    func loadConversations() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        selectedRequestId = nil

        do {
            conversations = try await chatService.fetchConversations()
        } catch {
            let nsError = error as NSError
            if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                self.errorMessage = error.localizedDescription // Set error message for UI
                print("InboxViewModel: Error loading conversations: \(error)")
            } else {
                 print("InboxViewModel: Conversation load cancelled (likely due to navigation).")
            }
        }
        isLoading = false
    }

    func selectConversation(requestId: Int64) {
        selectedRequestId = requestId
    }

    func handleNewMessage(_ message: ChatMessageDTO) {
        Task { await loadConversations() }
    }
}
