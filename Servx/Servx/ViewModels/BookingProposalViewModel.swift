//
//  BookingProposalViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 20..
//


import SwiftUI
import Combine

@MainActor
class BookingProposalViewModel: ObservableObject {

    // --- Inputs ---
    let requestId: Int64
    private let serviceRequestService: ServiceRequestServiceProtocol

    // --- Published Form State ---
    @Published var proposedDate: Date = Date() // Default to now
    @Published var priceMinString: String = ""
    @Published var priceMaxString: String = ""
    @Published var notes: String = ""
    @Published var serviceDetailsText: String = "Loading service details..." // Placeholder

    // --- UI State ---
    @Published var errorMessage: String? = nil
    @Published private(set) var isLoadingDetails: Bool = false
    @Published private(set) var isValid: Bool = false // Form validation

    private var cancellables = Set<AnyCancellable>()

    init(requestId: Int64, serviceRequestService: ServiceRequestServiceProtocol = ServiceRequestService()) {
        self.requestId = requestId
        self.serviceRequestService = serviceRequestService
        print("BookingProposalViewModel initialized for requestId: \(requestId)")
        setupValidation()
        // Fetch initial details when VM is created
        Task {
            await loadInitialServiceDetails()
        }
    }

    // Fetch basic details to pre-fill/display
    private func loadInitialServiceDetails() async {
        guard !isLoadingDetails else { return }
        isLoadingDetails = true
        print("BookingProposalViewModel: Loading service details...")
        do {
            let details = try await serviceRequestService.fetchRequestDetails(id: requestId)
            // Pre-fill fields based on fetched details
            self.serviceDetailsText = "\(details.service.categoryName) - \(details.service.subcategoryName): \(details.description)"
            // Pre-fill price if service has one price set
            if details.service.price > 0 {
                 let priceStr = String(format: "%.2f", details.service.price)
                 self.priceMinString = priceStr
                 self.priceMaxString = priceStr
            }
            print("BookingProposalViewModel: Service details loaded.")
        } catch {
            print("BookingProposalViewModel: Failed to load service details: \(error)")
            self.errorMessage = "Could not load service details."
            self.serviceDetailsText = "Could not load service details." // Update placeholder
        }
        isLoadingDetails = false
    }

    // Validation logic
    private func setupValidation() {
        Publishers.CombineLatest3($proposedDate, $priceMinString, $priceMaxString)
            .map { [weak self] date, minStr, maxStr in
                guard let self = self else { return false }
                // Validate Date (e.g., must be in future)
                guard date > Date() else {
                     self.errorMessage = "Proposed date must be in the future."
                     return false
                 }
                // Validate Prices (must be valid numbers, min <= max)
                guard let minPrice = Double(minStr), let maxPrice = Double(maxStr) else {
                     self.errorMessage = "Please enter valid numeric prices."
                     return false
                 }
                 guard minPrice >= 0 && maxPrice >= 0 else {
                     self.errorMessage = "Prices cannot be negative."
                     return false
                 }
                guard minPrice <= maxPrice else {
                     self.errorMessage = "Min price cannot be greater than max price."
                     return false
                 }
                // Add other validations if needed (e.g., notes length)
                self.errorMessage = nil // Clear error if valid
                return true
            }
            .assign(to: &$isValid) // Assign result directly to isValid using $ syntax
    }

    // Called by the View's Send button
    func createPayload() -> BookingRequestPayload? {
        guard isValid else {
             print("BookingProposalViewModel: Attempted to create payload but form is invalid.")
             // Error message should already be shown by validation pipeline
             return nil
         }

        // Safely convert strings to doubles (already validated by `isValid`)
        guard let minPrice = Double(priceMinString), let maxPrice = Double(priceMaxString) else {
            // This shouldn't happen if isValid is true, but good to guard
            self.errorMessage = "Invalid price format somehow bypassed validation."
             return nil
        }

        // Convert Date to ISO8601 String
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Include milliseconds and TZ offset
        let dateString = formatter.string(from: proposedDate)

        return BookingRequestPayload(
            agreedDateTime: dateString,
            serviceRequestDetailsText: self.serviceDetailsText, // Use fetched details
            priceMin: minPrice,
            priceMax: maxPrice,
            notes: self.notes.isEmpty ? nil : self.notes // Send nil if notes are empty
        )
    }
}
