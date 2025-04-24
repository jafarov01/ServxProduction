//
//  WebSocketManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 18..
//

import Combine
import Foundation
import SwiftStomp
import os

// ConnectionState enum
enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)

    func isError() -> Bool {
        if case .error = self { return true }
        return false
    }
}

@MainActor
class WebSocketManager: NSObject, ObservableObject, SwiftStompDelegate {

    // --- Singleton Instance ---
    static let shared = WebSocketManager()

    // --- Published State ---
    @Published var connectionState: ConnectionState = .disconnected
    @Published var lastErrorDetails: String? = nil

    // --- Publisher for Incoming Messages ---
    let messagePublisher = PassthroughSubject<ChatMessageDTO, Never>()

    // --- Private Properties ---
    private var stompClient: SwiftStomp?
    private let webSocketURL = URL(string: "ws://localhost:8080/ws")!
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "WebSocketManager"
    )
    private var currentToken: String?
    private var activeSubscriptionId: String?
    private var isIntentionalDisconnect = false

    // Reconnection Logic properties
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let baseReconnectDelay: TimeInterval = 1.0

    // Offline Message Queue
    private var messageQueue: [ChatMessageDTO] = []

    // --- Initialization ---
    private override init() {
        super.init()
        logger.info("WebSocketManager initialized")
        setupAppLifecycleObserver()
    }

    // MARK: - Public Methods

    func connect(token: String) {
        // Prevents multiple concurrent connection attempts
        guard connectionState == .disconnected || connectionState.isError()
        else {
            logger.warning("Connect called while already connecting/connected.")
            print(
                "secretSocket123 - Connect blocked! Current state: \(connectionState)"
            )  // ADDED
            return
        }

        logger.info("Attempting to connect...")
        print(
            "secretSocket123 - STARTING CONNECT with token: \(token.prefix(4))****"
        )
        updateState(.connecting)
        self.currentToken = token
        invalidateReconnectTimer()
        resetReconnectAttempts()

        // --- Prepare Headers ---
        // Headers for the STOMP CONNECT Frame
        let stompConnectHeaders = [
            "Authorization": "Bearer \(token)",
            "host": "localhost",
            "accept-version": "1.1,1.2",
            "heart-beat": "10000,10000",
        ]
        // Headers for the initial HTTP WebSocket Handshake
        let httpHandshakeHeaders = [
            "Authorization": "Bearer \(token)",
            "Sec-WebSocket-Protocol": "v10.stomp,v11.stomp,v12.stomp",
        ]

        // ADDED HEADER PRINTS
        print("secretSocket123 - STOMP HEADERS: \(stompConnectHeaders)")
        print("secretSocket123 - HTTP HEADERS: \(httpHandshakeHeaders)")

        // --- Initialize SwiftStomp using the CORRECT init from source ---
        logger.debug(
            "Initializing SwiftStomp with host, STOMP headers, and HTTP headers..."
        )
        print("secretSocket123 - Creating SwiftStomp with URL: \(webSocketURL)")
        stompClient = SwiftStomp(
            host: webSocketURL,
            headers: stompConnectHeaders,
            httpConnectionHeaders: httpHandshakeHeaders
        )
        stompClient?.delegate = self
        print(
            "secretSocket123 - Delegate set: \(String(describing: stompClient?.delegate != nil))"
        )

        // --- Initiate Connection ---
        logger.debug("Calling stompClient.connect (autoReconnect=false)...")
        print("secretSocket123 - CONNECTING NOW (autoReconnect: false)")
        stompClient?.connect(autoReconnect: false)
    }

    func disconnect(attemptReconnect: Bool = false) {
        logger.info(
            "Disconnecting (reconnect scheduled: \(attemptReconnect))..."
        )
        self.isIntentionalDisconnect = true
        invalidateReconnectTimer()
        if !attemptReconnect {
            resetReconnectAttempts()
        }
        stompClient?.autoReconnect = false
        stompClient?.disconnect()
    }

    func sendMessage(dto: ChatMessageDTO) {
        guard let client = stompClient else {
            logger.warning("Stomp client not initialized. Queuing message.")
            queueMessage(dto)
            return
        }
        guard connectionState == .connected else {
            logger.warning("Not connected. Queuing message.")
            queueMessage(dto)
            return
        }

        let destination = "/app/chat.sendMessage"
        let headers = ["content-type": "application/json"]

        do {
            // 1. Encode DTO to JSON Data
            let jsonData = try JSONEncoder().encode(dto)

            // 2. Convert JSON Data to UTF-8 String
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                logger.error("Failed to convert encoded JSON data to UTF8 string.")
                return
            }

            print("<<<< WebSocketManager: Attempting to send to \(destination)")
            print("<<<< WebSocketManager: Payload STRING: \(jsonString)")
            // ----------------------------------------

            // 3. Use the send method that takes a STRING body
            client.send(body: jsonString, to: destination, headers: headers)

            print("<<<< WebSocketManager: stompClient.send(body: String...) called successfully for \(destination).")
            // ---------------------------------------

        } catch {
             print("<<<< WebSocketManager: FAILED to encode DTO! Error: \(error.localizedDescription)")
             logger.error("Failed to encode message DTO: \(error.localizedDescription)")
        }
    }

    // MARK: - SwiftStompDelegate Methods (Marked nonisolated, dispatch back to MainActor)

    nonisolated func onConnect(
        swiftStomp: SwiftStomp,
        connectType: StompConnectType
    ) {
        let log = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: "WebSocketManager"
        )
        log.info(
            "STOMP Delegate: Connected! Type: \(String(describing: connectType))"
        )

        if connectType == .toStomp {
            // Dispatch state updates and subsequent actions to main actor
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.resetReconnectAttempts()
                self.updateState(.connected)
                self.subscribeToUserMessages()
                self.flushMessageQueue()
            }
        }
    }

    nonisolated func onDisconnect(
        swiftStomp: SwiftStomp,
        disconnectType: StompDisconnectType
    ) {
        let log = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: "WebSocketManager"
        )
        log.warning(
            "STOMP Delegate: Disconnected. Type: \(String(describing: disconnectType))"
        )

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            let intentional = self.isIntentionalDisconnect
                    self.isIntentionalDisconnect = false
            
            self.activeSubscriptionId = nil
            
            let wasConnectedOrConnecting =
                (self.connectionState == .connected
                    || self.connectionState == .connecting)
            
            self.stompClient = nil

            let shouldReconnect = !intentional && wasConnectedOrConnecting
            
            self.updateState(.disconnected)

            if shouldReconnect {
                self.logger.info(
                    "Scheduling reconnect due to unexpected disconnect."
                )
                self.scheduleReconnect()
            } else {
                self.logger.info("Clean disconnect, not scheduling reconnect.")
            }
        }
    }

    nonisolated func onMessageReceived(
        swiftStomp: SwiftStomp,
        message: Any?,
        messageId: String,
        destination: String,
        headers: [String: String]
    ) {
        let log = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: "WebSocketManager"
        )
        log.debug(
            "STOMP Delegate: Received Frame - Dest: \(destination), MsgID: \(messageId)"
        )
        let dataToDecode: Data?

        if let bodyString = message as? String {
            dataToDecode = bodyString.data(using: .utf8)
            if dataToDecode == nil {
                log.error("Failed to convert text message body to Data.")
            }
        } else if let bodyData = message as? Data {
            dataToDecode = bodyData
        } else {
            log.warning(
                "Received message body is neither String nor Data or is nil."
            )
            dataToDecode = nil
        }

        guard let data = dataToDecode else { return }

        // Dispatch decoding and publishing to main actor
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.decodeAndPublish(data: data)
        }
    }

    nonisolated func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        let log = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: "WebSocketManager"
        )
        log.debug("STOMP Delegate: Received receipt: \(receiptId)")
    }

    nonisolated func onError(
        swiftStomp: SwiftStomp,
        briefDescription: String,
        fullDescription: String?,
        receiptId: String?,
        type: StompErrorType
    ) {
        let errorDesc = fullDescription ?? briefDescription
        let log = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: "WebSocketManager"
        )
        log.error(
            "STOMP Delegate: Error - Type: \(String(describing: type)), Description: \(errorDesc), ReceiptID: \(receiptId ?? "N/A")"
        )

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.updateState(.error(errorDesc))
            self.scheduleReconnect()
        }
    }

    // MARK: - Private Helpers (@MainActor safe)

    private func subscribeToUserMessages() {
        guard connectionState == .connected, let client = stompClient else {
            return
        }
        guard activeSubscriptionId == nil else { return }

        let destination = "/user/queue/messages"
        let subId = "user-msg-\(UUID().uuidString)"

        logger.info("Subscribing to \(destination) with id: \(subId)")
        client.subscribe(to: destination, headers: ["id": subId])
        activeSubscriptionId = subId
    }

    private func decodeAndPublish(data: Data) {
        do {
            let messageDto = try JSONDecoder().decode(
                ChatMessageDTO.self,
                from: data
            )
            logger.info("Successfully decoded message ID: \(messageDto.id)")
            messagePublisher.send(messageDto)
        } catch {
            logger.error(
                "Failed to decode incoming message JSON: \(error.localizedDescription)"
            )
        }
    }

    private func queueMessage(_ dto: ChatMessageDTO) {
        logger.info("Queueing message content: \(dto.content)")
        messageQueue.append(dto)
    }

    private func flushMessageQueue() {
        guard connectionState == .connected else { return }
        guard !messageQueue.isEmpty else { return }

        logger.info("Flushing \(self.messageQueue.count) queued messages...")
        let queued = self.messageQueue
        self.messageQueue.removeAll()
        queued.forEach { self.sendMessage(dto: $0) }
    }

    private func updateState(_ newState: ConnectionState) {
        guard connectionState != newState else { return }
        self.connectionState = newState
        if case .error(let msg) = newState {
            self.lastErrorDetails = msg
        } else {
            self.lastErrorDetails = nil
        }
        logger.info("Connection state updated: \(String(describing: newState))")
    }

    // MARK: - Reconnection Logic (@MainActor safe)

    private func resetReconnectAttempts() {
        self.reconnectAttempts = 0
        self.invalidateReconnectTimer()
    }

    private func invalidateReconnectTimer() {
        self.reconnectTimer?.invalidate()
        self.reconnectTimer = nil
    }

    private func scheduleReconnect() {
        guard self.reconnectTimer == nil else { return }
        guard self.reconnectAttempts < self.maxReconnectAttempts else {
            logger.error(
                "Max reconnect attempts (\(self.maxReconnectAttempts)) reached."
            )
            self.updateState(
                .error("Connection failed after multiple retries.")
            )
            return
        }
        let delay = min(
            30.0,
            self.baseReconnectDelay * pow(2.0, Double(self.reconnectAttempts))
        )
        let jitter = TimeInterval.random(in: 0..<0.5)
        let actualDelay = delay + jitter
        
        self.logger.warning(
            "Scheduling reconnect attempt \(self.reconnectAttempts + 1) in \(String(format: "%.2f", actualDelay)) seconds..."
        )

        self.reconnectTimer = Timer.scheduledTimer(
            withTimeInterval: actualDelay,
            repeats: false
        ) { [weak self] _ in
            
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.connectionState == .disconnected
                    || self.connectionState.isError()
                {
                    if let token = self.currentToken {
                        self.logger.info(
                            "Attempting reconnect #\(self.reconnectAttempts + 1)..."
                        )
                        self.reconnectAttempts += 1
                        self.connect(token: token)
                    } else {
                        self.logger.error(
                            "Cannot reconnect: No token available."
                        )
                        self.updateState(
                            .error("Cannot reconnect: Not authenticated.")
                        )
                    }
                } else {
                    self.logger.info(
                        "Reconnect timer fired, but state is now \(String(describing: self.connectionState)). Aborting."
                    )
                    self.resetReconnectAttempts()
                }
                self.reconnectTimer = nil  // Use self.
            }
        }
    }

    // MARK: - App Lifecycle Handling (@MainActor safe)

    private func setupAppLifecycleObserver() {
        #if canImport(UIKit)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAppDidEnterBackground),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAppDidBecomeActive),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        #endif
    }

    // @objc methods require NSObject inheritance typically
    @objc private func handleAppDidEnterBackground() {
        logger.info("App entered background, disconnecting WebSocket.")
        self.disconnect(attemptReconnect: false)
    }

    @objc private func handleAppDidBecomeActive() {
        logger.info("App became active.")
        if let token = self.currentToken,
            self.connectionState == .disconnected
                || self.connectionState.isError()
        {
            if self.reconnectTimer == nil {
                self.logger.info(
                    "Attempting to reconnect on becoming active..."
                )
                self.resetReconnectAttempts()
                self.connect(token: token)
            } else {
                self.logger.info("Reconnect already scheduled.")
            }
        }
    }
}

#if canImport(UIKit)
    import UIKit
#endif
