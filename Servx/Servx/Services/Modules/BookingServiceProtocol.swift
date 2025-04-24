//
//  BookingServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 21..
//

import Foundation

protocol BookingServiceProtocol {
    func fetchBookings(status: BookingStatus, page: Int, size: Int) async throws -> PageWrapper<BookingDTO>
    func cancelBooking(bookingId: Int64) async throws
    func fetchBookings(startDate: Date, endDate: Date) async throws -> [BookingDTO]
    func providerMarkComplete(bookingId: Int64) async throws
    func seekerConfirmCompletion(bookingId: Int64) async throws
}

class BookingService: BookingServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchBookings(status: BookingStatus, page: Int, size: Int) async throws -> PageWrapper<BookingDTO> {
            print("BookingService: Fetching bookings - Status: \(status.rawValue), Page: \(page)")
            let endpoint = Endpoint.fetchBookings(status: status, page: page, size: size)
            let wrapper: PageWrapper<BookingDTO> = try await apiClient.request(endpoint)
            print("BookingService: Fetched \(wrapper.content.count) bookings for status \(status.rawValue) on page \(wrapper.number + 1)/\(wrapper.totalPages)")
            return wrapper
    }
    
    func fetchBookings(startDate: Date, endDate: Date) async throws -> [BookingDTO] {
            let startDateString = DateFormatter.yyyyMMdd.string(from: startDate)
            let endDateString = DateFormatter.yyyyMMdd.string(from: endDate)
            print("BookingService: Fetching bookings for date range: \(startDateString) to \(endDateString)")

            let endpoint = Endpoint.fetchBookingsByDateRange(startDate: startDate, endDate: endDate)

            let bookings: [BookingDTO] = try await apiClient.request(endpoint)

            print("BookingService: Fetched \(bookings.count) bookings for the date range.")
            return bookings
        }

        func cancelBooking(bookingId: Int64) async throws {
             print("BookingService: Cancelling booking ID \(bookingId)")
             let endpoint = Endpoint.cancelBooking(bookingId: bookingId)
             let _: EmptyResponseDTO = try await apiClient.request(endpoint)
             print("BookingService: Booking \(bookingId) cancelled successfully via API.")
        }
    
    func providerMarkComplete(bookingId: Int64) async throws {
            print("BookingService: Provider marking booking \(bookingId) as complete...")
            let endpoint = Endpoint.providerMarkComplete(bookingId: bookingId)
            let _: EmptyResponseDTO = try await apiClient.request(endpoint)
            print("BookingService: Provider successfully marked booking \(bookingId) complete.")
        }

        func seekerConfirmCompletion(bookingId: Int64) async throws {
            print("BookingService: Seeker confirming completion for booking \(bookingId)...")
            let endpoint = Endpoint.seekerConfirmCompletion(bookingId: bookingId)
            let _: EmptyResponseDTO = try await apiClient.request(endpoint)
            print("BookingService: Seeker successfully confirmed completion for booking \(bookingId).")
        }
}
