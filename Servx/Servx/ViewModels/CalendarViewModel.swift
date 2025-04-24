//
//  CalendarViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 22..
//


import SwiftUI
import Combine
import Foundation

@MainActor
class CalendarViewModel: ObservableObject {

    // MARK: - Published State
    @Published var selectedDate: Date = Date() {
        didSet {
            if !Calendar.current.isDate(oldValue, inSameDayAs: selectedDate) {
                print("CalendarViewModel: selectedDate changed to \(selectedDate.formatted(date: .numeric, time: .omitted)), fetching...")
                Task {
                    await fetchBookings(for: selectedDate)
                }
            }
        }
    }
    @Published private(set) var bookingsForSelectedDate: [Booking] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies
    private let bookingService: BookingServiceProtocol

    // MARK: - Initialization
    init(bookingService: BookingServiceProtocol = BookingService()) {
        self.bookingService = bookingService
        print("✅ CalendarViewModel initialized.")
    }

    // MARK: - Computed Properties for UI
    var serviceBookingCountText: String {
        let count = bookingsForSelectedDate.count
        return "Service Booking (\(count))"
    }

    // MARK: - Data Fetching
    func fetchBookings(for date: Date) async {
        guard !isLoading else { return }

        print("CalendarViewModel: Fetching bookings for date: \(date.toYYYYMMDDString())")
        isLoading = true
        errorMessage = nil
        self.bookingsForSelectedDate = []

        do {
            // start of the selected day
            let startOfDay = Calendar.current.startOfDay(for: date)

            // start of the *next* day. date(byAdding:)
            guard let startOfNextDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
                print("CalendarViewModel: Error - Could not calculate start of next day.")
                self.errorMessage = "Internal error calculating date range."
                isLoading = false
                return
            }

            let startDateForAPI = startOfDay
            let endDateForAPI = startOfDay

            let fetchedDtos = try await bookingService.fetchBookings(startDate: startDateForAPI, endDate: endDateForAPI)

            let mappedBookings = fetchedDtos.map { $0.toEntity() }

            let sortedBookings = mappedBookings.sorted {
                $0.scheduledStartDate ?? .distantPast < $1.scheduledStartDate ?? .distantPast
            }

            self.bookingsForSelectedDate = sortedBookings
            print("CalendarViewModel: Fetched \(self.bookingsForSelectedDate.count) bookings for \(date.toYYYYMMDDString()).")

        } catch {
            print("CalendarViewModel: Error fetching bookings for \(date.toYYYYMMDDString()): \(error)")
            let nsError = error as NSError
            if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                self.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}
