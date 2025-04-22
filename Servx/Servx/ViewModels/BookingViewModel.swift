//
//  BookingViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 21..
//

import SwiftUI
import Combine

@MainActor
class BookingViewModel: ObservableObject {

    // MARK: - Published State
    @Published var selectedTab: DisplayTab = .upcoming {
        didSet {
            if oldValue != selectedTab {
                Task {
                    await fetchBookings(initialLoad: true)
                }
            }
        }
    }
    @Published private(set) var bookings: [Booking] = [] // Stores Domain Model
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

    // MARK: - Data Fetching
    func fetchBookings(initialLoad: Bool = false) async {
        guard let role = currentRole else {
            errorMessage = "Cannot fetch bookings: User role is unknown."
            return
        }

        let tab = selectedTab
        // Use page 0 if initialLoad, otherwise use the stored current page for this tab
        let pageToFetch = initialLoad ? 0 : (currentPage[tab] ?? 0)
        let canLoad = canLoadMore[tab] ?? true // Default to true if not set

        guard !isLoading, canLoad else {
            return
        }

        isLoading = true
        errorMessage = nil
        if initialLoad {
             // Only reset the main bookings list if fetching for the currently selected tab
             // This prevents clearing the list when a background fetch completes for a non-visible tab (if implemented)
            if tab == selectedTab {
                 self.bookings = []
            }
            self.currentPage[tab] = 0
            self.canLoadMore[tab] = true
        }

        var fetchedDtos: [BookingDTO] = []
        var allPagesAreLast = true
        var fetchError: Error? = nil

        do {
            for backendStatus in tab.backendStatuses {
                 // If we already determined we can't load more for *this specific tab*
                 // (e.g., from a previous multi-status fetch), skip.
                 guard canLoadMore[tab] ?? true else { continue }

                let pageWrapper: PageWrapper<BookingDTO>
                
                // Call correct service based on role
                pageWrapper = try await bookingService.fetchBookings( // Use the unified method
                                status: backendStatus,
                                page: pageToFetch,
                                size: bookingsPerPage
                            )

                fetchedDtos.append(contentsOf: pageWrapper.content)
                if !pageWrapper.last {
                    allPagesAreLast = false // If any underlying status has more pages, the tab might have more
                }
            }

            let fetchedBookings = fetchedDtos.map { $0.toEntity() }
            let sortedBookings = fetchedBookings.sorted {
                $0.scheduledStartDate ?? .distantPast > $1.scheduledStartDate ?? .distantPast
            }

            if initialLoad {
                 self.bookings = sortedBookings
            } else {
                 let existingIDs = Set(self.bookings.map { $0.id })
                 let newUniqueBookings = sortedBookings.filter { !existingIDs.contains($0.id) }
                 self.bookings.append(contentsOf: newUniqueBookings)
                 // Re-sort after appending
                 self.bookings.sort { $0.scheduledStartDate ?? .distantPast > $1.scheduledStartDate ?? .distantPast }
            }

             self.currentPage[tab] = pageToFetch // Store the page number that was fetched
             self.canLoadMore[tab] = !allPagesAreLast

        } catch {
            fetchError = error // Store error to handle after loop
        }

        // Handle error outside the loop
         if let error = fetchError {
             print("BookingViewModel: Error fetching bookings for tab '\(tab.rawValue)': \(error)")
             let nsError = error as NSError
             if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                 self.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
             }
              // If fetch failed, assume we can't load more for this attempt
             self.canLoadMore[tab] = false
         }

        isLoading = false
    }

    func loadMoreBookings() async {
        // Increment the page number for the *current* selected tab before fetching
        let nextPage = (currentPage[selectedTab] ?? 0) + 1
        currentPage[selectedTab] = nextPage
        await fetchBookings(initialLoad: false)
    }

    // MARK: - Actions
     func cancelBooking(bookingId: Int64) async {
         guard let bookingToCancel = bookings.first(where: { $0.id == bookingId }),
               bookingToCancel.status == .upcoming else {
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
             print("BookingViewModel: Failed to cancel booking \(bookingId): \(error)")
             self.errorMessage = "Failed to cancel booking: \(error.localizedDescription)"
             isLoading = false // Ensure loading stops on error
         }
         // isLoading will be reset by fetchBookings if successful
     }

    // Updated messageUser function
    func messageUser(booking: Booking) {
        print("BookingViewModel: Setting chatNavigationTarget to \(booking.serviceRequestId)")
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
    func getOtherParticipant(for booking: Booking) -> (name: String, photoUrl: String?) {
         guard let role = currentRole else { return ("Unknown User", nil) }
        
         if role == .serviceProvider {
             return (booking.seekerFullName, booking.seekerProfilePhotoUrl)
         } else {
             return (booking.providerFullName, booking.providerProfilePhotoUrl)
         }
     }
}
