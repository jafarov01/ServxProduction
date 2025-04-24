//
//  ServiceProfileDetailsViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 23..
//


import SwiftUI
import Combine

@MainActor
class ServiceProfileDetailsViewModel: ObservableObject {

    // MARK: - Published State
    @Published var serviceProfile: ServiceProfile

    // State for reviews list
    @Published private(set) var reviews: [ReviewDTO] = []
    @Published private(set) var isLoadingReviews: Bool = false
    @Published var reviewsErrorMessage: String? = nil

    // Pagination state for reviews
    @Published private(set) var canLoadMoreReviews: Bool = true
    @Published private(set) var reviewsCurrentPage: Int = 0
    private let reviewsPerPage = 5 // Number of reviews per page

    // MARK: - Dependencies
    private let reviewService: ReviewServiceProtocol

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        serviceProfile: ServiceProfile,
        reviewService: ReviewServiceProtocol = ReviewService()
    ) {
        self.serviceProfile = serviceProfile
        self.reviewService = reviewService
        print("✅ ServiceProfileDetailsViewModel initialized for service ID: \(serviceProfile.id)")
    }

    // MARK: - Review Fetching Logic
    func fetchReviews(initialLoad: Bool = false) async {
        let pageToFetch = initialLoad ? 0 : reviewsCurrentPage
        guard !isLoadingReviews, canLoadMoreReviews || initialLoad else {
            print("ServiceProfileDetailsViewModel: Review fetch skipped (loading: \(isLoadingReviews), canLoad: \(canLoadMoreReviews), initial: \(initialLoad))")
            return
        }

        print("ServiceProfileDetailsViewModel: Fetching reviews page \(pageToFetch) for service \(serviceProfile.id)")
        isLoadingReviews = true
        if initialLoad {
            reviewsErrorMessage = nil
            self.reviewsCurrentPage = 0
            self.canLoadMoreReviews = true
             self.reviews = []
        }

        do {
            let reviewPageWrapper = try await reviewService.fetchReviews(
                serviceId: serviceProfile.id,
                page: pageToFetch,
                size: reviewsPerPage
            )

            let existingReviewIDs = Set(self.reviews.map { $0.id })
            let newUniqueReviews = reviewPageWrapper.content.filter { !existingReviewIDs.contains($0.id) }
            self.reviews.append(contentsOf: newUniqueReviews)

            self.reviewsCurrentPage = reviewPageWrapper.number
            self.canLoadMoreReviews = !reviewPageWrapper.last
            print("ServiceProfileDetailsViewModel: Fetched \(reviewPageWrapper.content.count) reviews. Total: \(reviews.count). Can load more: \(canLoadMoreReviews)")

        } catch {
             print("ServiceProfileDetailsViewModel: Error fetching reviews: \(error)")
             let nsError = error as NSError
             if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                  self.reviewsErrorMessage = "Failed to load reviews: \(error.localizedDescription)"
              }
              self.canLoadMoreReviews = false
        }

        isLoadingReviews = false
    }

    func loadMoreReviews() async {
         let nextPage = reviewsCurrentPage + 1
         reviewsCurrentPage = nextPage
         await fetchReviews(initialLoad: false)
     }
}
