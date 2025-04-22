//
//  ChatViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 19..
//

import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {

    @Published var messages: [ChatMessageDTO] = []
    @Published var messageText: String = ""
    @Published var isLoadingMessages: Bool = false
    @Published var isLoadingDetails: Bool = false
    @Published var canLoadMoreMessages: Bool = true
    @Published var errorWrapper: ErrorWrapper? = nil
    @Published var otherParticipantName: String = "Chat"
    @Published var isSending: Bool = false
    @Published var canSendMessage: Bool = false
    @Published var bookingMessageToShowDetails: ChatMessageDTO? = nil
    @Published private(set) var currentRequestStatus: ServiceRequest.RequestStatus? = nil

    let requestId: Int64
    let currentUserId: Int64
    let currentUserRole: Role
    @Published private(set) var otherParticipantId: Int64? = nil

    private var currentPage = 0
    private let messagesPerPage = 30

    private let chatService: ChatServiceProtocol
    private let serviceRequestService: ServiceRequestServiceProtocol
    private let webSocketManager: WebSocketManager

    private var cancellables = Set<AnyCancellable>()
    var scrollToBottomPublisher = PassthroughSubject<Bool, Never>()
    var scrollToMessagePublisher = PassthroughSubject<(id: Int64, anchor: UnitPoint?), Never>()
    // Removed: private let logger = Logger(...)

    init(
        requestId: Int64,
        chatService: ChatServiceProtocol = ChatService(),
        serviceRequestService: ServiceRequestServiceProtocol = ServiceRequestService(),
        authenticatedUser: AuthenticatedUser,
        webSocketManager: WebSocketManager
    ) {
        self.requestId = requestId
        self.chatService = chatService
        self.serviceRequestService = serviceRequestService
        self.webSocketManager = webSocketManager

        guard let currentUser = authenticatedUser.currentUser else {
            fatalError("ChatViewModel requires an authenticated user.")
        }
        self.currentUserId = currentUser.id
        self.currentUserRole = currentUser.role

        print("ChatViewModel initialized for requestId: \(requestId)")

        setupWebSocketSubscription()
        Task {
            await loadInitialData()
        }
    }

    func loadInitialData() async {
        guard messages.isEmpty && !isLoadingMessages && !isLoadingDetails else { return }
        print("ChatViewModel: Loading initial data...")
        isLoadingMessages = true
        isLoadingDetails = true
        errorWrapper = nil
        currentPage = 0
        canLoadMoreMessages = true
        self.messages = []

        await fetchParticipantsAndStatus()
        if self.otherParticipantId != nil {
            await fetchAndProcessMessages(page: 0, initialLoad: true)
        }
        await markConversationAsRead()

        isLoadingMessages = false
        isLoadingDetails = false
        await Task.yield()
        scrollToBottom(animated: false)
    }

    func loadMoreMessages() async {
        guard !isLoadingMessages && canLoadMoreMessages else { return }
        let nextPage = currentPage + 1
        print("ChatViewModel: Loading more messages (requesting page \(nextPage))...")
        isLoadingMessages = true
        let previousTopMessageId = messages.first?.id

        await fetchAndProcessMessages(page: nextPage)

        isLoadingMessages = false

        if let messageId = previousTopMessageId {
            await Task.yield()
            scrollToMessagePublisher.send((id: messageId, anchor: .top))
        }
    }

    private func fetchParticipantsAndStatus() async {
            print("ChatViewModel: Fetching request details...")
            isLoadingDetails = true
            defer { isLoadingDetails = false }
            do {
                let details = try await serviceRequestService.fetchRequestDetails(id: requestId)
                let otherUser: User
                if self.currentUserRole == .serviceProvider { otherUser = details.seeker }
                else { otherUser = details.provider }

                self.otherParticipantId = otherUser.id
                self.otherParticipantName = otherUser.fullName
                // --- SET STATUS ---
                self.currentRequestStatus = details.status // Store the fetched status
                // ------------------
                self.canSendMessage = isChatActiveByStatus(details.status)
                print("ChatViewModel: Set participants & status. Other: \(self.otherParticipantName). Status: \(details.status). CanSend: \(self.canSendMessage)")
            } catch {
                print("ChatViewModel: Failed fetch request details: \(error.localizedDescription)")
                self.errorWrapper = ErrorWrapper(message: "Could not load chat details.")
                self.otherParticipantName = "Chat Error"
                self.otherParticipantId = nil
                self.canSendMessage = false
                self.currentRequestStatus = nil // Reset status on error
            }
        }

    private func fetchAndProcessMessages(page: Int, initialLoad: Bool = false) async {
        errorWrapper = nil
        do {
            let pageWrapper = try await chatService.fetchMessages(
                requestId: requestId, page: page, size: messagesPerPage
            )
            let fetchedMessagesOldestFirst = pageWrapper.content.reversed()
            let existingIDs = Set(self.messages.map { $0.id })
            let newMessages = fetchedMessagesOldestFirst.filter { !existingIDs.contains($0.id) }

            if initialLoad {
                self.messages = newMessages
            } else {
                self.messages.insert(contentsOf: newMessages, at: 0)
            }
            self.canLoadMoreMessages = !pageWrapper.last
            self.currentPage = pageWrapper.number
            print("ChatViewModel: Updated messages. Loaded page: \(pageWrapper.number). Total: \(self.messages.count). Can load more: \(self.canLoadMoreMessages)")
        } catch {
            let errorMsg = "Failed to load messages: \(error.localizedDescription)"
            print("ChatViewModel: Error loading messages: \(errorMsg)")
            self.errorWrapper = ErrorWrapper(message: errorMsg)
        }
    }

    func sendMessage() {
        let textToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty, !isSending, canSendMessage, let recipientId = self.otherParticipantId else {
            if self.otherParticipantId == nil { print("ChatViewModel: Send failed, recipient unknown.") }
            return
        }
        print("ChatViewModel: Sending message...")
        isSending = true
        let timestampString = ISO8601DateFormatter().string(from: Date())
        let tempId = Int64.random(in: -99999 ..< -1)

        let dto = ChatMessageDTO(id: 0, serviceRequestId: requestId, senderId: currentUserId, recipientId: recipientId, senderName: nil, content: textToSend, timestamp: timestampString, isRead: false, bookingPayload: nil)
        let optimisticMessage = ChatMessageDTO(id: tempId, serviceRequestId: requestId, senderId: currentUserId, recipientId: recipientId, senderName: "You", content: textToSend, timestamp: timestampString, isRead: true, bookingPayload: nil)

        messages.append(optimisticMessage)
        self.messageText = ""
        scrollToBottom(animated: true)
        webSocketManager.sendMessage(dto: dto)
        self.isSending = false
    }

    func sendBookingRequest(payload: BookingRequestPayload) {
        guard currentUserRole == .serviceProvider, !isSending, canSendMessage, let recipientId = self.otherParticipantId else {
             if self.otherParticipantId == nil { print("ChatViewModel: Cannot send booking request, recipient unknown.") }
            return
         }
        print("ChatViewModel: Sending booking request...")
        isSending = true
        let tempId = Int64.random(in: -99999 ..< -1)
        let timestampString = ISO8601DateFormatter().string(from: Date())
        let summaryContent = "Booking Proposed"

        let dto = ChatMessageDTO(id: 0, serviceRequestId: requestId, senderId: currentUserId, recipientId: recipientId, senderName: nil, content: summaryContent, timestamp: timestampString, isRead: false, bookingPayload: payload)
        let optimisticMessage = ChatMessageDTO(id: tempId, serviceRequestId: requestId, senderId: currentUserId, recipientId: recipientId, senderName: "You", content: summaryContent, timestamp: timestampString, isRead: true, bookingPayload: payload)

        messages.append(optimisticMessage)
        scrollToBottom(animated: true)
        webSocketManager.sendMessage(dto: dto)
        self.isSending = false
    }

    func showBookingDetails(for message: ChatMessageDTO) {
        guard message.bookingPayload != nil else { return }
        print("ChatViewModel: Setting message ID \(message.id) to show booking details sheet.")
        self.bookingMessageToShowDetails = message
    }

    // --- Simplified Accept/Decline using Print ---
    func handleBookingAccept(messageId: Int64) {
        guard currentUserRole == .serviceSeeker, !isLoadingDetails else { return }
        guard currentRequestStatus == .accepted else {
            print("ChatViewModel: Cannot accept booking, request status is not ACCEPTED (it's \(String(describing: currentRequestStatus)))")
            self.errorWrapper = ErrorWrapper(message: "Booking cannot be accepted at this time (Status: \(currentRequestStatus?.rawValue ?? "Unknown"))")
            return
        }
        print("ChatViewModel: Attempting to ACCEPT booking for message \(messageId)...")
        isLoadingDetails = true
        errorWrapper = nil

        Task { [weak self] in
            guard let self = self else { return }
            var success = false
            var finalStatus: ServiceRequest.RequestStatus? = nil
            do {
                let updatedRequestDto = try await self.serviceRequestService.confirmBooking(
                                    requestId: self.requestId,
                                    messageId: messageId // Pass the ID of the message being accepted
                                )
                print("ChatViewModel: Booking confirmed via API. Status: \(updatedRequestDto.status)")
                finalStatus = updatedRequestDto.status
                success = true
            } catch {
                print("ChatViewModel: Failed to confirm booking: \(error.localizedDescription)")
                self.errorWrapper = ErrorWrapper(message: "Failed to accept booking: \(error.localizedDescription)")
            }

            self.isLoadingDetails = false
            if success, let status = finalStatus {
                             self.currentRequestStatus = status
                             self.canSendMessage = self.isChatActiveByStatus(status)
                             self.updateLocalMessageProposalStatus(messageId: messageId, newStatus: .accepted)
                             Task { await self.loadInitialData() }
                        }
        }
    }

    func handleBookingDecline(messageId: Int64) {
         guard currentUserRole == .serviceSeeker, !isLoadingDetails else { return }
         guard currentRequestStatus == .accepted else {
            print("ChatViewModel: Cannot decline booking, request status is not ACCEPTED (it's \(String(describing: currentRequestStatus)))")
             self.errorWrapper = ErrorWrapper(message: "Booking cannot be declined at this time (Status: \(currentRequestStatus?.rawValue ?? "Unknown"))")
            return
        }
        print("ChatViewModel: Attempting to DECLINE booking for message \(messageId)...")
        isLoadingDetails = true
        errorWrapper = nil

        Task { [weak self] in
            guard let self = self else { return }
            var success = false
            var finalStatus: ServiceRequest.RequestStatus? = nil
            do {
                let updatedRequestDto = try await self.serviceRequestService.rejectBooking(requestId: self.requestId)
                print("ChatViewModel: Booking rejected via API. Status: \(updatedRequestDto.status)")
                finalStatus = updatedRequestDto.status
                success = true
            } catch {
                print("ChatViewModel: Failed to reject booking: \(error.localizedDescription)")
                self.errorWrapper = ErrorWrapper(message: "Failed to reject booking: \(error.localizedDescription)")
            }

             self.isLoadingDetails = false
             if success, let status = finalStatus {
                  self.currentRequestStatus = status
                  self.canSendMessage = self.isChatActiveByStatus(status)
                  self.updateLocalMessageProposalStatus(messageId: messageId, newStatus: .rejected) // Use Enum
                  Task { await self.loadInitialData() } // Keep reload for now
             }
        }
    }
    private func updateLocalMessageProposalStatus(messageId: Int64, newStatus: BookingProposalState) {
         if let index = self.messages.firstIndex(where: { $0.id == messageId }) {
             self.messages[index].bookingProposalStatus = newStatus
             print("ChatViewModel: Updated message \(messageId) local proposal status to \(newStatus)")
         }
     }
    
    func setupWebSocketSubscription() {
        print("ChatViewModel: Setting up WebSocket subscription...")
        cancellables.forEach { $0.cancel() }
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
         print("ChatViewModel: Handling received message ID: \(message.id)")
         if !messages.contains(where: { $0.id == message.id }) {
             messages.append(message)
             scrollToBottom(animated: true)
             if message.recipientId == currentUserId {
                  Task { await markConversationAsRead() }
             }
         } else {
             print("ChatViewModel: Received message \(message.id) already present.")
         }
    }

    func markConversationAsRead() async {
        print("ChatViewModel: Attempting to mark conversation \(self.requestId) as read...")
        do {
            try await chatService.markConversationAsRead(requestId: requestId)
            print("ChatViewModel: Marked conversation \(self.requestId) as read successfully via service.")
             messages = messages.map { msg in
                 var mutableMsg = msg
                 if !mutableMsg.isRead && mutableMsg.recipientId == currentUserId {
                     mutableMsg.isRead = true
                 }
                 return mutableMsg
             }
        } catch {
             print("ChatViewModel: Failed to mark conversation \(self.requestId) as read: \(error.localizedDescription)")
        }
    }

    func isCurrentUser(senderId: Int64) -> Bool {
        return senderId == self.currentUserId
    }

    private func isChatActiveByStatus(_ status: ServiceRequest.RequestStatus?) -> Bool {
        guard let status = status else { return false }
        let activeStatuses: [ServiceRequest.RequestStatus] = [.accepted, .bookingConfirmed]
        return activeStatuses.contains(status)
    }

    func scrollToBottom(animated: Bool) {
        scrollToBottomPublisher.send(animated)
    }
}
