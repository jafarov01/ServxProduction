//
//  ChatServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 17..
//

import Foundation

protocol ChatServiceProtocol {
    func fetchConversations() async throws -> [ChatConversationDTO]

    func fetchMessages(requestId: Int64, page: Int, size: Int) async throws -> PageWrapper<ChatMessageDTO>

    func markConversationAsRead(requestId: Int64) async throws
}

final class ChatService: ChatServiceProtocol {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchConversations() async throws -> [ChatConversationDTO] {
        print("ChatService: Fetching conversations...")
        let conversations: [ChatConversationDTO] = try await apiClient.request(.fetchConversations)
        print("ChatService: Fetched \(conversations.count) conversations.")
        return conversations
    }

    func fetchMessages(requestId: Int64, page: Int, size: Int) async throws -> PageWrapper<ChatMessageDTO> {
        print("ChatService: Fetching messages page \(page) for request \(requestId)...")
        let endpoint = Endpoint.fetchMessages(requestId: requestId, page: page, size: size)
        let responseWrapper: PageWrapper<ChatMessageDTO> = try await apiClient.request(endpoint)
        print("ChatService: Fetched page \(responseWrapper.number + 1)/\(responseWrapper.totalPages). \(responseWrapper.content.count) messages.")
        return responseWrapper
    }

    func markConversationAsRead(requestId: Int64) async throws {
        print("ChatService: Marking conversation \(requestId) as read...")
        let _: EmptyResponseDTO = try await apiClient.request(.markConversationAsRead(requestId: requestId))
        print("ChatService: Marked conversation \(requestId) as read successfully.")
    }
}
