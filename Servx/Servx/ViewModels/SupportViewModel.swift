//
//  SupportViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 22..
//


import SwiftUI
import Combine

@MainActor
class SupportViewModel: ObservableObject {

    // MARK: - Published Properties for UI Binding
    @Published var supportMessage: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published var successMessage: String? = nil
    @Published var errorMessage: String? = nil

    var canSubmit: Bool {
        !isLoading && !supportMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Dependencies
    private let supportService: SupportServiceProtocol
    private var successMessageTimer: Timer?

    // MARK: - Initialization
    init(supportService: SupportServiceProtocol = SupportService()) {
        self.supportService = supportService
        print("✅ SupportViewModel initialized.")
    }

    // MARK: - Actions
    func sendRequest() async {
        guard canSubmit else {
            print("SupportViewModel: Submission blocked (isLoading or message empty).")
            return
        }

        print("SupportViewModel: Attempting to send support request...")
        isLoading = true
        clearFeedbackMessages()

        do {
            try await supportService.sendSupportRequest(message: supportMessage)

            print("SupportViewModel: Support request sent successfully via service.")
            supportMessage = ""
            successMessage = "Your message has been sent successfully."
            scheduleSuccessMessageClear()

        } catch {
            print("SupportViewModel: Failed to send support request: \(error)")
             let nsError = error as NSError
             if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                 errorMessage = "Failed to send message. Please check your connection and try again. (\(error.localizedDescription))"
             }
        }

        isLoading = false
         print("SupportViewModel: sendRequest finished. isLoading = \(isLoading)")
    }

    // MARK: - Private Helpers
    private func clearFeedbackMessages() {
         successMessage = nil
         errorMessage = nil
         successMessageTimer?.invalidate()
         successMessageTimer = nil
     }

    private func scheduleSuccessMessageClear() {
        successMessageTimer?.invalidate()
        successMessageTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
             Task { @MainActor [weak self] in // Ensure runs on main actor
                 print("SupportViewModel: Clearing success message via timer.")
                 self?.successMessage = nil
             }
        }
    }
    
     deinit {
         successMessageTimer?.invalidate()
          print("🗑️ SupportViewModel deinitialized.")
     }
}
