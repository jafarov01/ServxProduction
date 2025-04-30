//
//  BookingProposalViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 20..
//

import Combine
import SwiftUI

@MainActor
class BookingProposalViewModel: ObservableObject {

    // --- Inputs ---
    let requestId: Int64
    private let serviceRequestService: ServiceRequestServiceProtocol

    // --- Published Form State ---
    @Published var proposedDate: Date = Date()
    @Published var priceMinString: String = ""
    @Published var priceMaxString: String = ""
    @Published var durationString: String = ""
    @Published var notes: String = ""
    @Published var serviceDetailsText: String = "Loading service details..."

    // --- UI State ---
    @Published var errorMessage: String? = nil
    @Published private(set) var isLoadingDetails: Bool = false
    @Published private(set) var isValid: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(
        requestId: Int64,
        serviceRequestService: ServiceRequestServiceProtocol =
            ServiceRequestService()
    ) {
        self.requestId = requestId
        self.serviceRequestService = serviceRequestService
        print(
            "BookingProposalViewModel initialized for requestId: \(requestId)"
        )
        setupValidation()
        Task {
            await loadInitialServiceDetails()
        }
    }

    private func loadInitialServiceDetails() async {
        guard !isLoadingDetails else { return }
        isLoadingDetails = true
        print("BookingProposalViewModel: Loading service details...")
        do {
            let details = try await serviceRequestService.fetchRequestDetails(
                id: requestId
            )
            self.serviceDetailsText =
                "\(details.service.categoryName) - \(details.service.subcategoryName): \(details.description)"
            if details.service.price > 0 {
                let priceStr = String(format: "%.2f", details.service.price)
                self.priceMinString = priceStr
                self.priceMaxString = priceStr
            }
            print("BookingProposalViewModel: Service details loaded.")
        } catch {
            print(
                "BookingProposalViewModel: Failed to load service details: \(error)"
            )
            self.errorMessage = "Could not load service details."
            self.serviceDetailsText = "Could not load service details."
        }
        isLoadingDetails = false
    }

    // Validation logic
    private func setupValidation() {
        Publishers.CombineLatest3(
            $proposedDate,
            $priceMinString,
            $priceMaxString
        )
        .map { [weak self] date, minStr, maxStr in
            guard let self = self else { return false }
            guard date > Date() else {
                self.errorMessage = "Proposed date must be in the future."
                return false
            }
            guard let minPrice = Double(minStr), let maxPrice = Double(maxStr)
            else {
                self.errorMessage = "Please enter valid numeric prices."
                return false
            }
            guard minPrice >= 0 && maxPrice >= 0 else {
                self.errorMessage = "Prices cannot be negative."
                return false
            }
            guard minPrice <= maxPrice else {
                self.errorMessage =
                    "Min price cannot be greater than max price."
                return false
            }
//            guard let duration = Int(durationString), duration > 0 else {
//                self.errorMessage =
//                    "Please enter a valid duration in minutes (must be > 0)."
//                return false
//            }
            self.errorMessage = nil
            return true
        }
        .assign(to: &$isValid)
    }

    func createPayload() -> BookingRequestPayload? {
        guard isValid else {
            print(
                "BookingProposalViewModel: Attempted to create payload but form is invalid."
            )
            return nil
        }

        guard let minPrice = Double(priceMinString),
            let maxPrice = Double(priceMaxString),
            let duration = Int(durationString)
        else {
            self.errorMessage = "Invalid form data somehow bypassed validation."
            return nil
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        let dateString = formatter.string(from: proposedDate)

        return BookingRequestPayload(
            agreedDateTime: dateString,
            serviceRequestDetailsText: self.serviceDetailsText,
            priceMin: minPrice,
            priceMax: maxPrice,
            notes: self.notes.isEmpty ? nil : self.notes,
            durationMinutes: duration
        )
    }
}
