//
//  BookingViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 21..
//

import Combine
import SwiftUI

@MainActor
class BookingViewModel: ObservableObject {

    @Published var selectedTab: DisplayTab = .upcoming {
        didSet {
            if oldValue != selectedTab {
                print("Tab changed from \(oldValue.rawValue) to \(selectedTab.rawValue).")
                resetAndFetchCurrentTab()
            }
        }
    }
    @Published private(set) var bookings: [Booking] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var chatNavigationTarget: Int64? = nil
    @Published var serviceProfileForNavigation: ServiceProfile? = nil

    private var currentPageForCurrentTab: Int = 0
    private var canLoadMoreForCurrentTab: Bool = true
    private let bookingsPerPage = 10

    private let bookingService: BookingServiceProtocol
    private let servicesService: ServicesServiceProtocol
    private let authenticatedUser: AuthenticatedUser

    var currentRole: Role? { authenticatedUser.currentUser?.role }
    private var currentUserId: Int64? { authenticatedUser.currentUser?.id }
    private var cancellables = Set<AnyCancellable>()
    private var currentFetchTask: Task<Void, Never>?
    private var successMessageTimer: Timer?

    init(
        bookingService: BookingServiceProtocol = BookingService(),
        servicesService: ServicesServiceProtocol = ServicesService(),
        authenticatedUser: AuthenticatedUser
    ) {
        self.bookingService = bookingService
        self.servicesService = servicesService
        self.authenticatedUser = authenticatedUser
        print("BookingViewModel initialized.")
        setupUserObserver()
    }

    deinit {
        currentFetchTask?.cancel()
        successMessageTimer?.invalidate()
        print("BookingViewModel deinitialized.")
    }

    private func setupUserObserver() {
        authenticatedUser.$currentUser
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("Detected currentUser update. Refreshing bookings for \(self.selectedTab.rawValue).")
                self.resetAndFetchCurrentTab()
            }
            .store(in: &cancellables)
    }

    func resetAndFetchCurrentTab() {
        currentFetchTask?.cancel()
        print("Cancelling task and resetting state for \(selectedTab.rawValue)")

        self.bookings = []
        self.currentPageForCurrentTab = 0
        self.canLoadMoreForCurrentTab = true
        self.errorMessage = nil
        self.successMessage = nil
        self.isLoading = false

        currentFetchTask = Task {
            await fetchBookings(page: 0)
        }
    }

    func loadMoreBookings() async {
        let nextPage = currentPageForCurrentTab + 1
        print("Load more triggered for tab \(selectedTab.rawValue), requesting page \(nextPage)")
        await fetchBookings(page: nextPage)
    }

    func fetchBookings(page pageToFetch: Int) async {
        let fetchTab = self.selectedTab

        guard currentRole != nil else {
            errorMessage = "Cannot fetch bookings: User role is unknown."
            print("Fetch cancelled - user role unknown.")
            return
        }

        guard !isLoading else {
            print("Fetch skipped for \(fetchTab.rawValue) (isLoading=true).")
            return
        }

        if pageToFetch > 0 {
            guard canLoadMoreForCurrentTab else {
                print("Fetch skipped for \(fetchTab.rawValue) (!canLoadMoreForCurrentTab).")
                return
            }
        }

        isLoading = true
        if fetchTab == self.selectedTab { errorMessage = nil }
        print("Starting fetch for \(fetchTab.rawValue), page \(pageToFetch).")

        let isInitialLoadForTab = (pageToFetch == 0)
        if isInitialLoadForTab {
            if fetchTab == self.selectedTab {
                print("Clearing bookings for initial load of CURRENT tab \(fetchTab.rawValue).")
                self.bookings = []
            }
            self.currentPageForCurrentTab = 0
            self.canLoadMoreForCurrentTab = true
            print("Reset pagination state for \(fetchTab.rawValue).")
        }

        var fetchedDtos: [BookingDTO] = []
        var isLastPageFromAPI = true

        do {
            try Task.checkCancellation()
            print("Fetching statuses for tab \(fetchTab.rawValue) page \(pageToFetch)")

            for backendStatus in fetchTab.backendStatuses {
                try Task.checkCancellation()
                print("Fetching status \(backendStatus.rawValue) page \(pageToFetch)")

                let pageWrapper: PageWrapper<BookingDTO> = try await {
                    return try await bookingService.fetchBookings(status: backendStatus, page: pageToFetch, size: bookingsPerPage)
                }()

                fetchedDtos.append(contentsOf: pageWrapper.content)
                print("Fetched \(pageWrapper.content.count) DTOs for status \(backendStatus.rawValue). LastPage: \(pageWrapper.last)")
                if !pageWrapper.last { isLastPageFromAPI = false }
            }

            try Task.checkCancellation()
            let mappedBookings = fetchedDtos.map { $0.toEntity() }
            let sortedBookings = mappedBookings.sorted { $0.scheduledStartDate ?? .distantPast > $1.scheduledStartDate ?? .distantPast }
            print("Fetch successful. Found \(sortedBookings.count) bookings.")

            if fetchTab == self.selectedTab {
                if pageToFetch == 0 {
                    self.bookings = sortedBookings
                } else {
                    let existingIDs = Set(self.bookings.map { $0.id })
                    let newUniqueBookings = sortedBookings.filter { !existingIDs.contains($0.id) }
                    self.bookings.append(contentsOf: newUniqueBookings)
                    self.bookings.sort { $0.scheduledStartDate ?? .distantPast > $1.scheduledStartDate ?? .distantPast }
                }
                self.currentPageForCurrentTab = pageToFetch
                self.canLoadMoreForCurrentTab = !isLastPageFromAPI
                print("Assigned bookings. Final count: \(self.bookings.count).")
            }

            isLoading = false

        } catch is CancellationError {
            print("Task cancelled.")
            if fetchTab == self.selectedTab { isLoading = false }
        } catch {
            print("Error: \(error)")
            if fetchTab == self.selectedTab {
                self.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
                self.canLoadMoreForCurrentTab = false
                isLoading = false
            }
        }
        print("Fetch end for \(fetchTab.rawValue). Final bookings count: \(self.bookings.count), isLoading: \(isLoading)")
    }

    func cancelBooking(bookingId: Int64) async {
        guard let booking = bookings.first(where: { $0.id == bookingId }), booking.status == .upcoming else {
            errorMessage = "Booking cannot be cancelled."; return
        }
        isLoading = true; errorMessage = nil; successMessage = nil
        do {
            try await bookingService.cancelBooking(bookingId: bookingId)
            successMessage = "Booking cancelled."
            scheduleSuccessMessageClear()
            resetAndFetchCurrentTab()
        } catch {
            errorMessage = "Failed to cancel booking: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func providerMarkComplete(bookingId: Int64) async {
        guard let booking = bookings.first(where: { $0.id == bookingId }), booking.status == .upcoming, !booking.providerMarkedComplete else {
            errorMessage = "Action not available."; return
        }
        isLoading = true; errorMessage = nil; successMessage = nil
        do {
            try await bookingService.providerMarkComplete(bookingId: bookingId)
            successMessage = "Marked as complete. Waiting for seeker."
            scheduleSuccessMessageClear()
            resetAndFetchCurrentTab()
        } catch {
            errorMessage = "Failed to mark as complete: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func seekerConfirmCompletion(bookingId: Int64) async {
        guard let booking = bookings.first(where: { $0.id == bookingId }), booking.status == .upcoming, booking.providerMarkedComplete else {
            errorMessage = "Cannot confirm completion."; return
        }
        isLoading = true; errorMessage = nil; successMessage = nil
        do {
            try await bookingService.seekerConfirmCompletion(bookingId: bookingId)
            successMessage = "Booking completed!"
            scheduleSuccessMessageClear()
            resetAndFetchCurrentTab()
        } catch {
            errorMessage = "Failed to confirm completion: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func messageUser(booking: Booking) {
        print("Navigating to chat for service request ID \(booking.serviceRequestId)")
        chatNavigationTarget = booking.serviceRequestId
    }

    func didNavigateToChat() {
        chatNavigationTarget = nil
    }

    func bookAgain(basedOn booking: Booking) async {
        print("bookAgain triggered for original booking ID \(booking.id), service ID \(booking.serviceId)")
        isLoading = true // Optionally show loading for this action
        errorMessage = nil
        // Ensure serviceProfileForNavigation is nil before starting
        if serviceProfileForNavigation != nil { serviceProfileForNavigation = nil }

        do {
            // 1. Fetch the ServiceProfile needed for navigation
            let fetchedProfile = try await servicesService.fetchServiceProfile(id: booking.serviceId)
            print("Successfully fetched service profile for Book Again: \(fetchedProfile.id)")

            // 2. Set the dedicated state variable to trigger navigation in the View
            self.serviceProfileForNavigation = fetchedProfile

        } catch {
            print("Error fetching ServiceProfile for Book Again: \(error)")
            errorMessage = "Could not retrieve service details to book again."
        }
        isLoading = false // Reset loading state
    }
    
    func didNavigateToServiceRequest() {
        // Called by the View *after* navigation has been initiated
        print("Resetting serviceProfileForNavigation")
        serviceProfileForNavigation = nil
    }

    func viewEReceipt(booking: Booking) {
        errorMessage = "e-Receipt not implemented yet."
    }

    func getOtherParticipant(for booking: Booking) -> (
        name: String, photoUrl: URL?
    ) {
        guard let role = currentRole else { return ("Unknown User", nil) }

        if role == .serviceProvider {
            return (booking.seekerFullName, booking.seekerProfilePhotoUrl)
        } else {
            return (booking.providerFullName, booking.providerProfilePhotoUrl)
        }
    }
    
    private func scheduleSuccessMessageClear() {
        successMessageTimer?.invalidate()
        successMessageTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in self?.successMessage = nil }
        }
    }
}

enum DisplayTab: String, CaseIterable, Hashable {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case cancelled = "Cancelled"

    var backendStatuses: [BookingStatus] {
        switch self {
        case .upcoming:
            return [.upcoming]
        case .completed:
            return [.completed]
        case .cancelled:
            return [.cancelledBySeeker, .cancelledByProvider]
        }
    }

    func matches(status: BookingStatus?) -> Bool {
        guard let status = status else { return false }
        return self.backendStatuses.contains(status)
    }
}
