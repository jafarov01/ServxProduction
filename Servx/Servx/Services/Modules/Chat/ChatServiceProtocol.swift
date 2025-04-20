//
//  ChatServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 17..
//

import Foundation

protocol ChatServiceProtocol {
    // Fetches all conversations for the current user
    func fetchConversations() async throws -> [ChatConversationDTO]

    // Fetches a specific page of messages for a given conversation (request ID)
    // Returns an array for now, pagination handling can be added if backend returns Page<> wrapper
    func fetchMessages(requestId: Int64, page: Int, size: Int) async throws -> PageWrapper<ChatMessageDTO>
    // Marks all messages in a conversation as read for the current user
    func markConversationAsRead(requestId: Int64) async throws
}


// Concrete implementation using the APIClient
final class ChatService: ChatServiceProtocol {

    private let apiClient: APIClientProtocol

    // Inject the shared APIClient or create a new one
    init(apiClient: APIClientProtocol = APIClient()) { // Use your existing APIClient setup
        self.apiClient = apiClient
    }

    func fetchConversations() async throws -> [ChatConversationDTO] {
        print("ChatService: Fetching conversations...")
        // Call the APIClient with the fetchConversations endpoint
        let conversations: [ChatConversationDTO] = try await apiClient.request(.fetchConversations)
        print("ChatService: Fetched \(conversations.count) conversations.")
        return conversations
    }

    func fetchMessages(requestId: Int64, page: Int, size: Int) async throws -> PageWrapper<ChatMessageDTO> {
        print("ChatService: Fetching messages page \(page) for request \(requestId)...")
        let endpoint = Endpoint.fetchMessages(requestId: requestId, page: page, size: size)
        // Decode the PageWrapper structure directly
        let responseWrapper: PageWrapper<ChatMessageDTO> = try await apiClient.request(endpoint)
        print("ChatService: Fetched page \(responseWrapper.number + 1)/\(responseWrapper.totalPages). \(responseWrapper.content.count) messages.")
        // Return the whole wrapper
        return responseWrapper
    }

    func markConversationAsRead(requestId: Int64) async throws {
        print("ChatService: Marking conversation \(requestId) as read...")
        // Call the endpoint, expecting no data in return (or an Empty DTO)
        let _: EmptyResponseDTO = try await apiClient.request(.markConversationAsRead(requestId: requestId))
        print("ChatService: Marked conversation \(requestId) as read successfully.")
    }
}
