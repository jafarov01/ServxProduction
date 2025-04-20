//
//  ChatViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 19..
//

import Combine
import SwiftUI
import os

@MainActor
class ChatViewModel: ObservableObject {

    // --- Published State ---
    @Published var messages: [ChatMessageDTO] = []
    @Published var messageText: String = ""
    @Published var isLoadingMessages: Bool = false
    @Published var isLoadingDetails: Bool = false // Separate flag for initial details load
    @Published var canLoadMoreMessages: Bool = true
    @Published var errorWrapper: ErrorWrapper? = nil
    @Published var otherParticipantName: String = "Chat" // Default/loading name
    @Published var isSending: Bool = false
    @Published var canSendMessage: Bool = false // Default false until status confirmed

    // --- Properties ---
    let requestId: Int64
    let currentUserId: Int64
    let currentUserRole: Role
    // Keep optional - will be fetched after init
    @Published private(set) var otherParticipantId: Int64? = nil

    // Pagination
    private var currentPage = 0
    private let messagesPerPage = 30

    // --- Dependencies ---
    private let chatService: ChatServiceProtocol
    private let serviceRequestService: ServiceRequestServiceProtocol
    private let authenticatedUser: AuthenticatedUser
    private let webSocketManager: WebSocketManager

    // Combine
    private var cancellables = Set<AnyCancellable>()
    var scrollToBottomPublisher = PassthroughSubject<Bool, Never>()
    var scrollToMessagePublisher = PassthroughSubject<(id: Int64, anchor: UnitPoint?), Never>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ChatViewModel")

    // --- CORRECTED Initializer ---
    init(
        requestId: Int64,
        // Inject services and singletons using defaults or passed explicitly by caller
        chatService: ChatServiceProtocol = ChatService(),
        serviceRequestService: ServiceRequestServiceProtocol = ServiceRequestService(),
        authenticatedUser: AuthenticatedUser, // Still get current user info here
        webSocketManager: WebSocketManager
    ) {
        self.requestId = requestId
        self.chatService = chatService
        self.serviceRequestService = serviceRequestService
        self.authenticatedUser = authenticatedUser // Store injected instance
        self.webSocketManager = webSocketManager

        guard let currentUser = authenticatedUser.currentUser else {
            fatalError("ChatViewModel requires an authenticated user.")
        }
        self.currentUserId = currentUser.id
        self.currentUserRole = currentUser.role

        print("ChatViewModel initialized for requestId: \(requestId)")

        // Setup WS subscription
        setupWebSocketSubscription()
        // Trigger initial data load (which includes participant/status fetch)
        Task {
            await loadInitialData()
        }
    }

    // MARK: - Data Loading

    func loadInitialData() async {
        guard messages.isEmpty && !isLoadingMessages && !isLoadingDetails else { return }
        print("ChatViewModel: Loading initial data...")
        isLoadingMessages = true // Use this flag for initial message load too
        isLoadingDetails = true // Indicate details are loading
        errorWrapper = nil
        currentPage = 0
        canLoadMoreMessages = true
        self.messages = [] // Clear messages

        // Fetch essential details first (participant info, status)
        await fetchParticipantsAndStatus() // Now crucial before message fetch maybe? Or parallel? Let's do first.

        // Then fetch messages
        await fetchAndProcessMessages(page: 0, initialLoad: true)

        await markConversationAsRead()

        isLoadingMessages = false
        isLoadingDetails = false // Mark details loading as finished
        await Task.yield()
        scrollToBottom(animated: false)
    }

    func loadMoreMessages() async {
        guard !isLoadingMessages && canLoadMoreMessages else { return }
        let nextPage = currentPage + 1
        logger.info("Loading more messages (requesting page \(nextPage))...")
        isLoadingMessages = true
        let previousTopMessageId = messages.first?.id

        await fetchAndProcessMessages(page: nextPage)

        isLoadingMessages = false

        if let messageId = previousTopMessageId {
            await Task.yield()
            scrollToMessagePublisher.send((id: messageId, anchor: .top))
        }
    }
    
    // MARK: - Participant & Status Fetching (Moved from deleted helpers)

    // Fetches Request Details to get participant info and status
    private func fetchParticipantsAndStatus() async {
        print("ChatViewModel: Fetching request details for participant info & status...")
        do {
            let details = try await serviceRequestService.fetchRequestDetails(id: requestId)

            // Determine other participant based on current user's role
            let otherUser: User // Assuming UserDTO from ServiceRequestDetail DTO
            if self.currentUserRole == .serviceProvider {
                otherUser = details.seeker
            } else {
                otherUser = details.provider
            }
            // Update State
            self.otherParticipantId = otherUser.id
            self.otherParticipantName = otherUser.fullName // Assuming UserDTO has fullName
            self.canSendMessage = isChatActiveByStatus(details.status) // Update active status

            print("ChatViewModel: Set participants from request details. Other: \(self.otherParticipantName) (\(self.otherParticipantId ?? -1)). CanSend: \(self.canSendMessage)")

        } catch {
            print("ChatViewModel: Failed to fetch request details for participant/status info: \(error)")
            self.errorWrapper = ErrorWrapper(message: "Could not load chat details.")
            self.otherParticipantName = "Chat"
            self.otherParticipantId = nil
            self.canSendMessage = false // Default to inactive if details failed
        }
    }

    private func fetchAndProcessMessages(page: Int, initialLoad: Bool = false)
        async
    {
        errorWrapper = nil
        do {
            let pageWrapper = try await chatService.fetchMessages(
                requestId: requestId, page: page, size: messagesPerPage
            )
            // Messages from API are newest first, reverse to get oldest first for this page
            let fetchedMessagesOldestFirst = pageWrapper.content.reversed()

            // Check for duplicates before modifying the main array
            let existingIDs = Set(self.messages.map { $0.id })
            let newMessages = fetchedMessagesOldestFirst.filter { !existingIDs.contains($0.id) }

            if initialLoad {
                self.messages = newMessages // Assign the first page (oldest first)
            } else {
                // Prepend older messages to the START (index 0) of the array
                self.messages.insert(contentsOf: newMessages, at: 0)
            }

            self.canLoadMoreMessages = !pageWrapper.last
            self.currentPage = pageWrapper.number
            logger.info("Updated messages. Loaded page: \(pageWrapper.number). Total: \(self.messages.count). Can load more: \(self.canLoadMoreMessages)")

        } catch {
            let errorMsg =
                "Failed to load messages: \(error.localizedDescription)"
            logger.error("\(errorMsg)")
            self.errorWrapper = ErrorWrapper(message: errorMsg)
        }
    }

    // MARK: - Actions

    func sendMessage() {
        let textToSend = messageText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        // Guard check uses the optional otherParticipantId
        guard !textToSend.isEmpty, !isSending, canSendMessage,
            let recipientId = self.otherParticipantId
        else {
            if self.otherParticipantId == nil {
                logger.error("Send failed, recipient unknown.")
                self.errorWrapper = ErrorWrapper(
                    message: "Cannot send message: recipient unknown."
                )
            } else if textToSend.isEmpty {
                logger.warning("Attempted to send empty message.")
            } else {
                logger.warning(
                    "Cannot send message (sending: \(self.isSending), canSend: \(self.canSendMessage))"
                )
            }
            return
        }
        logger.info("Sending message...")
        isSending = true  // Indicate sending state
        let timestampString = ISO8601DateFormatter().string(from: Date())  // Use current time

        let dto = ChatMessageDTO(
            id: 0,
            serviceRequestId: requestId,
            senderId: currentUserId,
            recipientId: recipientId,
            senderName: nil,
            content: textToSend,
            timestamp: timestampString,
            isRead: false
        )

        webSocketManager.sendMessage(dto: dto)

        let tempId = Int64.random(in: -99999 ..< -1)
        let optimisticMessage = ChatMessageDTO(
            id: tempId,
            serviceRequestId: requestId,
            senderId: currentUserId,
            recipientId: recipientId,
            senderName: "You",
            content: textToSend,
            timestamp: timestampString,
            isRead: true
        )
        messages.append(optimisticMessage)
        self.messageText = ""
        scrollToBottom(animated: true)
        self.isSending = false
    }

    func sendBookingRequest() {
        guard currentUserRole == .serviceProvider, !isSending, canSendMessage
        else { return }
        guard let recipientId = self.otherParticipantId else {
            logger.error("Cannot send booking request, recipient unknown.")
            self.errorWrapper = ErrorWrapper(
                message: "Cannot send booking request: recipient unknown."
            )
            return
        }
        logger.info("Sending booking request...")
        isSending = true
        let tempId = Int64.random(in: -99999 ..< -1)
        let timestampString = ISO8601DateFormatter().string(from: Date())
        // Define a clear structure/marker for booking requests
        let bookingContent =
            "[BOOKING_REQUEST] Booking proposed. Please confirm."  // Use a parseable format

        let dto = ChatMessageDTO(
            id: 0,
            serviceRequestId: requestId,
            senderId: currentUserId,
            recipientId: recipientId,
            senderName: nil,
            content: bookingContent,
            timestamp: timestampString,
            isRead: false
        )
        let optimisticMessage = ChatMessageDTO(
            id: tempId,
            serviceRequestId: requestId,
            senderId: currentUserId,
            recipientId: recipientId,
            senderName: "You",
            content: bookingContent,
            timestamp: timestampString,
            isRead: true
        )

        messages.append(optimisticMessage)
        scrollToBottom(animated: true)
        webSocketManager.sendMessage(dto: dto)
        self.isSending = false  // Assume sent, handle errors via onError maybe
    }

    // MARK: - Booking Response Actions (Placeholders - Requires Implementation)

    func handleBookingAccept(messageId: Int64) {
        logger.info("Booking ACCEPTED for message (Placeholder) \(messageId)")
        // 1. Find message and update its state/appearance?
        // 2. Trigger API call to backend: POST /api/bookings (or similar)
        // 3. Backend should then change ServiceRequest status maybe?
        // 4. Send a confirmation message back? "[BOOKING_CONFIRMED]"
        // 5. Update `canSendMessage` if chat should now be disabled.
    }

    func handleBookingDecline(messageId: Int64) {
        logger.info("Booking DECLINED for message (Placeholder) \(messageId)")
        // 1. Find message and update its state/appearance?
        // 2. Send decline notification/message back via WebSocket?
    }

    // MARK: - WebSocket Handling

    func setupWebSocketSubscription() {
        logger.info("Setting up WebSocket subscription...")
        cancellables.forEach { $0.cancel() }  // Clear previous before starting new
        cancellables.removeAll()

        webSocketManager.messagePublisher
            .filter { $0.serviceRequestId == self.requestId }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMessage in
                self?.handleReceivedMessage(newMessage)
            }
            .store(in: &cancellables)
    }

    private func handleReceivedMessage(_ message: ChatMessageDTO) {
        logger.info("Handling received message ID: \(message.id)")
        // Simple check to avoid adding exact duplicate by ID
        if !messages.contains(where: { $0.id == message.id }) {
            messages.append(message)
            scrollToBottom(animated: true)
            Task { await markConversationAsRead() }  // Mark read when new message arrives
        } else {
            logger.info("Received message \(message.id) already present.")
        }
    }

    // MARK: - Read Status

    func markConversationAsRead() async {
        logger.debug("Attempting to mark conversation \(self.requestId) as read...")
        do {
            try await chatService.markConversationAsRead(requestId: requestId)
            logger.info(
                "Marked conversation \(self.requestId) as read successfully via service."
            )
        } catch {
            logger.error(
                "Failed to mark conversation \(self.requestId) as read: \(error)"
            )
        }
    }

    // MARK: - Helpers

    func isCurrentUser(senderId: Int64) -> Bool {
        return senderId == self.currentUserId
    }

    // --- REMOVED Participant Fetching Helpers ---

    // --- Fetch and Set Chat Active State ---
    private func updateChatActiveState() async {
        logger.info("Fetching request status to update active state...")
        do {
            // Fetch details using injected service
            let details : ServiceRequestDetail = try await serviceRequestService.fetchRequestDetails(
                id: requestId
            )
            self.canSendMessage = isChatActiveByStatus(details.status)  // Update flag

        } catch {
            logger.error(
                "Failed to fetch request details for status check: \(error)"
            )
            self.errorWrapper = ErrorWrapper(
                message: "Could not verify chat status."
            )
            self.canSendMessage = false  // Default to false on error
        }
    }

    // Helper to determine if chat should be active based on request status
    private func isChatActiveByStatus(_ status: ServiceRequest.RequestStatus?) -> Bool {
        guard let status = status else { return false }
        let activeStatuses: [ServiceRequest.RequestStatus] = [.accepted, .bookingConfirmed]
        return activeStatuses.contains(status)
    }

    // --- Scrolling ---
    func scrollToBottom(animated: Bool) {
        scrollToBottomPublisher.send(animated)
    }
}
