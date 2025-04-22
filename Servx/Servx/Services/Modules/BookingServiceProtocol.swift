//
//  BookingServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 21..
//


protocol BookingServiceProtocol {
    func fetchBookings(status: BookingStatus, page: Int, size: Int) async throws -> PageWrapper<BookingDTO>
    func cancelBooking(bookingId: Int64) async throws // Define return if needed
}

class BookingService: BookingServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchBookings(status: BookingStatus, page: Int, size: Int) async throws -> PageWrapper<BookingDTO> {
            print("BookingService: Fetching bookings - Status: \(status.rawValue), Page: \(page)")
            // Use the corrected Endpoint case
            let endpoint = Endpoint.fetchBookings(status: status, page: page, size: size)
            let wrapper: PageWrapper<BookingDTO> = try await apiClient.request(endpoint)
            print("BookingService: Fetched \(wrapper.content.count) bookings for status \(status.rawValue) on page \(wrapper.number + 1)/\(wrapper.totalPages)")
            return wrapper
    }

func cancelBooking(bookingId: Int64) async throws {
         print("BookingService: Cancelling booking ID \(bookingId)")
         let endpoint = Endpoint.cancelBooking(bookingId: bookingId)
         let _: EmptyResponseDTO = try await apiClient.request(endpoint)
         print("BookingService: Booking \(bookingId) cancelled successfully via API.")
    }
}
