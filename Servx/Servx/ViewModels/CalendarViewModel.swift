//
//  CalendarViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 22..
//


import SwiftUI
import Combine
import Foundation // Ensure Foundation is imported for Date calculations

@MainActor
class CalendarViewModel: ObservableObject {

    // MARK: - Published State
    // The date currently selected/highlighted in the calendar UI
    @Published var selectedDate: Date = Date() {
        didSet {
            // Check if the actual *day* changed, not just the time component if any
            if !Calendar.current.isDate(oldValue, inSameDayAs: selectedDate) {
                // *** FIX HERE: Use .numeric instead of .short ***
                print("CalendarViewModel: selectedDate changed to \(selectedDate.formatted(date: .numeric, time: .omitted)), fetching...")
                Task {
                    // Ensure fetch is called on main actor implicitly
                    await fetchBookings(for: selectedDate)
                }
            }
        }
    }
    // Stores ONLY the bookings for the currently selected date
    @Published private(set) var bookingsForSelectedDate: [Booking] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies
    private let bookingService: BookingServiceProtocol
    // We don't strictly need AuthenticatedUser here if the service calls handle auth implicitly

    // MARK: - Initialization
    init(bookingService: BookingServiceProtocol = BookingService()) {
        self.bookingService = bookingService
        print("✅ CalendarViewModel initialized.")
        // Initial fetch will be triggered by .task in the View
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
            // Calculate start of the selected day (non-optional)
            let startOfDay = Calendar.current.startOfDay(for: date) // No guard let needed

            // Calculate start of the *next* day. date(byAdding:) returns non-optional Date.
            // We use guard only to handle the extremely unlikely scenario it fails.
            guard let startOfNextDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
                print("CalendarViewModel: Error - Could not calculate start of next day.")
                // Set an error message or handle appropriately
                self.errorMessage = "Internal error calculating date range."
                isLoading = false
                return // Exit if we can't calculate the range end
            }

            // For the API call using the current Endpoint definition, we send startOfDay for both.
            // The Endpoint formats these into YYYY-MM-DD strings.
            let startDateForAPI = startOfDay
            let endDateForAPI = startOfDay // Sending same date, assuming backend/endpoint interprets this as the full day

            // Call the service method (which expects two Dates now)
            let fetchedDtos = try await bookingService.fetchBookings(startDate: startDateForAPI, endDate: endDateForAPI)

            // Map DTOs to Domain Models
            let mappedBookings = fetchedDtos.map { $0.toEntity() }

            // Sort results by time (ascending for a daily schedule)
            let sortedBookings = mappedBookings.sorted {
                $0.scheduledStartDate ?? .distantPast < $1.scheduledStartDate ?? .distantPast
            }

            // Update the published array
            self.bookingsForSelectedDate = sortedBookings
            print("CalendarViewModel: Fetched \(self.bookingsForSelectedDate.count) bookings for \(date.toYYYYMMDDString()).")

        } catch {
            print("CalendarViewModel: Error fetching bookings for \(date.toYYYYMMDDString()): \(error)")
            let nsError = error as NSError
            // Avoid showing error if task was cancelled (e.g., user navigated away quickly)
            if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                self.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}
