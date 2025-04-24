//
//  LeaveReviewViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 23..
//


import SwiftUI
import Combine

@MainActor
class LeaveReviewViewModel: ObservableObject {

    // MARK: - State
    @Published var rating: Double = 0
    @Published var comment: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published private(set) var didSubmitSuccessfully: Bool = false

    // Input Properties
    let bookingId: Int64
    let providerName: String
    let serviceName: String

    // MARK: - Dependencies
    private let reviewService: ReviewServiceProtocol

    var canSubmit: Bool {
        !isLoading && rating >= 1
    }

    // MARK: - Initialization
    init(
        bookingId: Int64,
        providerName: String,
        serviceName: String,
        reviewService: ReviewServiceProtocol = ReviewService()
    ) {
        self.bookingId = bookingId
        self.providerName = providerName
        self.serviceName = serviceName
        self.reviewService = reviewService
        print("✅ LeaveReviewViewModel initialized for bookingId: \(bookingId)")
    }

    // MARK: - Actions
    func submitReview() async {
        guard canSubmit else {
            print("LeaveReviewViewModel: Submission blocked (isLoading or rating missing).")
            return
        }
        
        print("LeaveReviewViewModel: Submitting review for booking \(bookingId)... Rating: \(rating)")
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await reviewService.submitReview(
                bookingId: bookingId,
                rating: rating,
                comment: comment.isEmpty ? nil : comment
            )
            
            print("LeaveReviewViewModel: Review submitted successfully.")
            successMessage = "Review submitted successfully!"
            didSubmitSuccessfully = true
            
        } catch {
            print("LeaveReviewViewModel: Failed to submit review: \(error)")
            if let networkError = error as? NetworkError {
                switch networkError {
                case .duplicateReview:
                    errorMessage = networkError.localizedDescription
                default:
                    errorMessage = "Failed to submit review: \(networkError.localizedDescription)"
                }
            } else {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}
