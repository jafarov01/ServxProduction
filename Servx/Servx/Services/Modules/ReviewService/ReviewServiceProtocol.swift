//
//  ReviewServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 23..
//


import Foundation

protocol ReviewServiceProtocol {
    func submitReview(bookingId: Int64, rating: Double, comment: String?) async throws
    
    func fetchReviews(serviceId: Int64, page: Int, size: Int) async throws -> PageWrapper<ReviewDTO>
}


class ReviewService: ReviewServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func submitReview(bookingId: Int64, rating: Double, comment: String?) async throws {
        print("ReviewService: Submitting review for booking \(bookingId)")
        let requestDTO = ReviewRequestDTO(
            bookingId: bookingId,
            rating: rating,
            comment: comment?.isEmpty ?? true ? nil : comment
        )
        let endpoint = Endpoint.submitReview(body: requestDTO)

        let _: EmptyResponseDTO = try await apiClient.request(endpoint)
        print("ReviewService: Review submitted successfully.")
    }

    func fetchReviews(serviceId: Int64, page: Int, size: Int) async throws -> PageWrapper<ReviewDTO> {
        print("ReviewService: Fetching reviews for service \(serviceId), page \(page)")
        let endpoint = Endpoint.fetchReviewsForService(serviceId: serviceId, page: page, size: size)

        let wrapper: PageWrapper<ReviewDTO> = try await apiClient.request(endpoint)
        print("ReviewService: Fetched \(wrapper.content.count) reviews for service \(serviceId) on page \(wrapper.number + 1)/\(wrapper.totalPages)")
        return wrapper
    }
}
