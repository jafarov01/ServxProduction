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

    // MARK: - Published State
    @Published var selectedTab: DisplayTab = .upcoming {
        didSet {
            if oldValue != selectedTab {
                print(
                    "bookingIssue: [ViewModel] selectedTab changed from \(oldValue.rawValue) to \(selectedTab.rawValue)."
                )
                // *** Cancel previous task before starting new one ***
                currentFetchTask?.cancel()
                print(
                    "bookingIssue: [ViewModel] Previous fetch task cancelled (if running)."
                )

                // Start new fetch task
                currentFetchTask = Task {
                    // Add small delay to allow UI update cycle before starting fetch (optional)
                    // try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
                    await fetchBookings(initialLoad: true)
                }
            }
        }
    }
    @Published private(set) var bookings: [Booking] = []  // Stores Domain Model
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published private(set) var canLoadMore: [DisplayTab: Bool] = [:]
    @Published private(set) var currentPage: [DisplayTab: Int] = [:]
    @Published var chatNavigationTarget: Int64? = nil
    private let bookingsPerPage = 10

    // MARK: - Dependencies
    private let bookingService: BookingServiceProtocol
    private let authenticatedUser: AuthenticatedUser

    private var currentRole: Role? { authenticatedUser.currentUser?.role }
    private var currentUserId: Int64? { authenticatedUser.currentUser?.id }
    private var cancellables = Set<AnyCancellable>()
    private var currentFetchTask: Task<Void, Never>?

    // MARK: - Initialization
    init(
        bookingService: BookingServiceProtocol = BookingService(),
        authenticatedUser: AuthenticatedUser,
    ) {
        self.bookingService = bookingService
        self.authenticatedUser = authenticatedUser

        DisplayTab.allCases.forEach {
            canLoadMore[$0] = true
            currentPage[$0] = 0
        }
    }
    
    func fetchBookings(initialLoad: Bool = false) async {
            // Role check still useful to ensure user is valid
            guard let role = currentRole else {
                errorMessage = "Cannot fetch bookings: User role is unknown."
                print("bookingIssue: [ViewModel] fetchBookings cancelled - user role unknown.")
                return
            }

            let tab = selectedTab // Capture tab at the start of this specific execution
            let pageToFetch = initialLoad ? 0 : (currentPage[tab] ?? 0)
            let canLoad = canLoadMore[tab] ?? true

            // Keep isLoading check to prevent duplicate simultaneous fetches for the *same* tab
            guard !isLoading, (initialLoad || canLoad) else {
                    print("bookingIssue: [ViewModel] fetchBookings skipped for \(tab.rawValue) (isLoading=\(isLoading), initialLoad=\(initialLoad), canLoad=\(canLoad)).")
                    return
                }

            isLoading = true
            errorMessage = nil
            print("bookingIssue: [ViewModel] fetchBookings START - Tab: \(tab.rawValue), initialLoad: \(initialLoad), page: \(pageToFetch). Set isLoading = true.")

            // Clear the list ONLY if this fetch is an initialLoad AND it's for the *currently selected* tab.
            // This prevents a delayed task for a previous tab from clearing the current tab's data.
            if initialLoad && tab == self.selectedTab {
                print("bookingIssue: [ViewModel] fetchBookings Clearing bookings array for initial load of CURRENT tab \(tab.rawValue).")
                self.bookings = []
            }
            // Reset pagination state ONLY if it's an initial load request for this tab
            if initialLoad {
                 self.currentPage[tab] = 0
                 self.canLoadMore[tab] = true
             }

            var fetchedDtos: [BookingDTO] = []
            var allPagesAreLast = true
            var fetchError: Error? = nil

            do {
                // Check for cancellation before hitting the network
                try Task.checkCancellation()
                print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) Task not cancelled, proceeding to fetch statuses: \(tab.backendStatuses.map { $0.rawValue })...")

                for backendStatus in tab.backendStatuses {
                    // Check cancellation before each network call in the loop
                    try Task.checkCancellation()
                    // Only proceed if we still think we can load more for this tab
                    guard canLoadMore[tab] ?? true else {
                        print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) Skipping status \(backendStatus.rawValue) because canLoadMore is false.")
                        continue
                    }

                    print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) Fetching status \(backendStatus.rawValue) for page \(pageToFetch)")

                    // *** Call the CORRECT Service Method based on Role ***
                    //    (Using separate methods as per user's BookingService code)
                    let pageWrapper: PageWrapper<BookingDTO>
                    // Call correct service based on role
                    pageWrapper = try await bookingService.fetchBookings(  // Use the unified method
                        status: backendStatus,
                        page: pageToFetch,
                        size: bookingsPerPage
                    )
                    // *** End Service Call ***

                    fetchedDtos.append(contentsOf: pageWrapper.content)
                    print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) Fetched \(pageWrapper.content.count) DTOs for status \(backendStatus.rawValue)")
                    if !pageWrapper.last { allPagesAreLast = false }
                }

                // Check for cancellation after network calls, before processing/state update
                try Task.checkCancellation()

                let mappedBookings = fetchedDtos.map { $0.toEntity() }
                let sortedBookings = mappedBookings.sorted {
                    $0.scheduledStartDate ?? .distantPast > $1.scheduledStartDate ?? .distantPast
                }
                print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) Fetch successful. Found \(sortedBookings.count) total bookings.")

                 // *** CRITICAL: Only update state if this task wasn't cancelled ***
                 // *** AND only update if the data is for the *currently* selected tab ***
                 // This prevents a delayed fetch for an old tab overwriting the current one.
                 if tab == self.selectedTab {
                     if initialLoad {
                         self.bookings = sortedBookings // Replace content on initial load
                     } else {
                          // Append only new items for load more
                         let existingIDs = Set(self.bookings.map { $0.id })
                         let newUniqueBookings = sortedBookings.filter { !existingIDs.contains($0.id) }
                         self.bookings.append(contentsOf: newUniqueBookings)
                         // Re-sort if append order matters significantly
                         self.bookings.sort { $0.scheduledStartDate ?? .distantPast > $1.scheduledStartDate ?? .distantPast }
                     }
                     self.currentPage[tab] = pageToFetch // Update page number fetched
                     self.canLoadMore[tab] = !allPagesAreLast // Update ability to load more
                     print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) Assigned \(self.bookings.count) bookings. Updated pagination.")
                 } else {
                     print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) completed for OLD tab while \(self.selectedTab.rawValue) is active. State NOT updated.")
                 }
                 // Set loading false ONLY on successful completion for the correct tab
                 isLoading = false

            } catch is CancellationError {
                // Don't set errorMessage, just log cancellation and reset loading
                print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) Task cancelled.")
                isLoading = false // Ensure loading is reset even on cancellation
            } catch {
                fetchError = error
                print("bookingIssue: [ViewModel] fetchBookings (\(tab.rawValue)) CATCH block. Error: \(error)")
                // Set error message only if it wasn't a cancellation
                let nsError = error as NSError
                 if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                      self.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
                  }
                self.canLoadMore[tab] = false // Assume cannot load more on error
                isLoading = false // Reset loading on error
            }

            // Final log state after everything
            print("bookingIssue: [ViewModel] fetchBookings END - Tab: \(tab.rawValue). Final bookings count: \(self.bookings.count), isLoading: \(isLoading)")
        }

    // MARK: - Data Fetching
//    func fetchBookings(initialLoad: Bool = false) async {
//        guard currentRole != nil else {
//            errorMessage = "Cannot fetch bookings: User role is unknown."
//            return
//        }
//
//        let tab = selectedTab
//        // Use page 0 if initialLoad, otherwise use the stored current page for this tab
//        let pageToFetch = initialLoad ? 0 : (currentPage[tab] ?? 0)
//        let canLoad = canLoadMore[tab] ?? true  // Default to true if not set
//
//        guard !isLoading, canLoad else {
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//        if initialLoad {
//            // Only reset the main bookings list if fetching for the currently selected tab
//            // This prevents clearing the list when a background fetch completes for a non-visible tab (if implemented)
//            if tab == selectedTab {
//                self.bookings = []
//            }
//            self.currentPage[tab] = 0
//            self.canLoadMore[tab] = true
//        }
//
//        var fetchedDtos: [BookingDTO] = []
//        var allPagesAreLast = true
//        var fetchError: Error? = nil
//
//        do {
//            for backendStatus in tab.backendStatuses {
//                // If we already determined we can't load more for *this specific tab*
//                // (e.g., from a previous multi-status fetch), skip.
//                guard canLoadMore[tab] ?? true else { continue }
//
//                let pageWrapper: PageWrapper<BookingDTO>
//
//                // Call correct service based on role
//                pageWrapper = try await bookingService.fetchBookings(  // Use the unified method
//                    status: backendStatus,
//                    page: pageToFetch,
//                    size: bookingsPerPage
//                )
//
//                fetchedDtos.append(contentsOf: pageWrapper.content)
//                if !pageWrapper.last {
//                    allPagesAreLast = false  // If any underlying status has more pages, the tab might have more
//                }
//            }
//
//            let fetchedBookings = fetchedDtos.map { $0.toEntity() }
//            let sortedBookings = fetchedBookings.sorted {
//                $0.scheduledStartDate ?? .distantPast > $1.scheduledStartDate
//                    ?? .distantPast
//            }
//
//            if initialLoad {
//                self.bookings = sortedBookings
//            } else {
//                let existingIDs = Set(self.bookings.map { $0.id })
//                let newUniqueBookings = sortedBookings.filter {
//                    !existingIDs.contains($0.id)
//                }
//                self.bookings.append(contentsOf: newUniqueBookings)
//                // Re-sort after appending
//                self.bookings.sort {
//                    $0.scheduledStartDate ?? .distantPast > $1
//                        .scheduledStartDate ?? .distantPast
//                }
//            }
//
//            self.currentPage[tab] = pageToFetch  // Store the page number that was fetched
//            self.canLoadMore[tab] = !allPagesAreLast
//
//        } catch {
//            fetchError = error  // Store error to handle after loop
//        }
//
//        // Handle error outside the loop
//        if let error = fetchError {
//            print(
//                "BookingViewModel: Error fetching bookings for tab '\(tab.rawValue)': \(error)"
//            )
//            let nsError = error as NSError
//            if !(nsError.domain == NSURLErrorDomain
//                && nsError.code == NSURLErrorCancelled)
//            {
//                self.errorMessage =
//                    "Failed to load bookings: \(error.localizedDescription)"
//            }
//            // If fetch failed, assume we can't load more for this attempt
//            self.canLoadMore[tab] = false
//        }
//
//        isLoading = false
//    }

    func loadMoreBookings() async {
        // Increment the page number for the *current* selected tab before fetching
        let nextPage = (currentPage[selectedTab] ?? 0) + 1
        currentPage[selectedTab] = nextPage
        await fetchBookings(initialLoad: false)
    }

    // MARK: - Actions
    func cancelBooking(bookingId: Int64) async {
        guard
            let bookingToCancel = bookings.first(where: { $0.id == bookingId }),
            bookingToCancel.status == .upcoming
        else {
            errorMessage = "Booking cannot be cancelled."
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            try await bookingService.cancelBooking(bookingId: bookingId)
            // Refresh the list to reflect the change (moves to cancelled)
            await fetchBookings(initialLoad: true)
        } catch {
            print(
                "BookingViewModel: Failed to cancel booking \(bookingId): \(error)"
            )
            self.errorMessage =
                "Failed to cancel booking: \(error.localizedDescription)"
            isLoading = false  // Ensure loading stops on error
        }
        // isLoading will be reset by fetchBookings if successful
    }

    // Updated messageUser function
    func messageUser(booking: Booking) {
        print(
            "BookingViewModel: Setting chatNavigationTarget to \(booking.serviceRequestId)"
        )
        // Set the target ID, this change will be observed by the View
        chatNavigationTarget = booking.serviceRequestId
    }

    // Reset function (optional, could be done in View's .onChange)
    func didNavigateToChat() {
        chatNavigationTarget = nil
    }

    func bookAgain(booking: Booking) {
        errorMessage = "Book Again not implemented yet."
        // TODO: Navigate to service request screen?
        // navigator.navigate(to: AppRoute.Main.serviceRequest(booking.serviceId)) // Need service profile
    }

    func viewEReceipt(booking: Booking) {
        errorMessage = "e-Receipt not implemented yet."
        // TODO: Navigate to receipt screen?
        // navigator.navigate(to: AppRoute.Booking.receipt(booking.id)) // Define route
    }

    // MARK: - Helpers
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
