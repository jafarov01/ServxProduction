//
//  CalendarView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import SwiftUI

struct CalendarView: View {
    // Create and own the ViewModel for this view's lifecycle
    @StateObject private var viewModel = CalendarViewModel()
    // Access navigator for the "See All" button action
    @EnvironmentObject private var navigator: NavigationManager

    var body: some View {
        VStack(spacing: 0) { // Use spacing 0 and control with padding
            // Graphical Date Picker bound to the ViewModel's selected date
            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden() // Hide the default label
            .padding(.horizontal) // Add padding around the calendar
            .tint(ServxTheme.primaryColor) // Color for selected date etc.
            .onChange(of: viewModel.selectedDate) { // Optional: Log date changes
                print("CalendarView: Date selected: \(viewModel.selectedDate)")
            }


            // Header for the bookings list
            bookingListHeader()
                .padding(.horizontal)
                .padding(.top, 15) // Space above the header
                .padding(.bottom, 10) // Space below the header

            // Divider line
            Divider()
                .padding(.horizontal)


            // Content area for the list (or loading/empty/error)
            bookingListContent()

            Spacer() // Push content upwards if list is short
        }
        .navigationTitle("My Calendar") // Set the title
        .navigationBarTitleDisplayMode(.inline)
        .background(ServxTheme.backgroundColor.ignoresSafeArea()) // Background
        .task { // Fetch initial data when the view appears
            // ViewModel handles the logic to fetch only if needed
            await viewModel.fetchBookings(for: viewModel.selectedDate)
        }
         // Optional: Add pull-to-refresh if desired for upcoming bookings
        .refreshable {
            await viewModel.fetchBookings(for: viewModel.selectedDate)
        }
        // Optional: Alert for errors
        .alert("Error Loading Bookings", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _,_ in viewModel.errorMessage = nil }
        )) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "Could not load calendar data.")
        }
    }

    // Header above the booking list ("Service Booking (N) [See All]")
    @ViewBuilder
    private func bookingListHeader() -> some View {
        HStack {
            // Display count based on filtered bookings for the selected date
            Text(viewModel.serviceBookingCountText)
                .font(.title3.weight(.semibold)) // Slightly larger font
                .foregroundColor(ServxTheme.primaryColor)

            Spacer()

            Button("See All") {
                // Action: Switch to the booking tab
                navigator.switchTab(to: .booking)
            }
            .font(.callout) // Appropriate size for action text
            .foregroundColor(ServxTheme.primaryColor)
        }
    }

    // ViewBuilder for the booking list, empty state, or loading indicator
    @ViewBuilder
    private func bookingListContent() -> some View {
        if viewModel.isLoading && viewModel.bookingsForSelectedDate.isEmpty {
            // Show loading only if list is currently empty for the date
            ProgressView()
                .padding(.top, 50) // Add space if loading takes time
        } else if viewModel.bookingsForSelectedDate.isEmpty {
             // Empty state specific to the selected date
            VStack(spacing: 10) {
                 Image(systemName: "calendar.badge.exclamationmark") // Example icon
                     .font(.largeTitle)
                     .foregroundColor(.gray)
                 Text("You have no service booking")
                 Text("You don't have a service booking on this date")
                     .font(.subheadline)
                     .foregroundColor(ServxTheme.secondaryTextColor)
             }
             .padding(.top, 50) // Add space above empty state
             .frame(maxWidth: .infinity)

        } else {
            // List of bookings for the selected date
            ScrollView { // Use ScrollView for the list below calendar
                LazyVStack(spacing: 15) { // Spacing between cards
                    ForEach(viewModel.bookingsForSelectedDate) { booking in
                        CalendarBookingCardView(booking: booking)
                            // Pass navigator if card needs it directly (currently uses environment)
                            // .environmentObject(navigator)
                    }
                }
                .padding(.horizontal) // Padding for the list content
                .padding(.top, 5) // Small padding above the first card
                .padding(.bottom) // Padding below last card
            }
        }
    }
}


struct CalendarBookingCardView: View {
    let booking: Booking // Use Booking domain model
    // Inject NavigationManager for message button action
    @EnvironmentObject private var navigator: NavigationManager
    // Get user role to display correct participant info
    private let currentUserRole: Role? = AuthenticatedUser.shared.currentUser?.role

    // Determine the other participant's info
    private var otherParticipantName: String {
        guard let role = currentUserRole else { return "Unknown User" }
        return role == .serviceProvider ? booking.seekerFullName : booking.providerFullName
    }

    private var otherParticipantPhotoUrl: URL? {
        guard let role = currentUserRole else { return nil }
            let photoURL: URL? = role == .serviceProvider ? booking.seekerProfilePhotoUrl : booking.providerProfilePhotoUrl
            return photoURL
     }
     
     // Formatted time for display
     private var formattedTime: String {
         booking.scheduledStartDate?.formatted(date: .omitted, time: .shortened) ?? "--:--"
     }

    var body: some View {
        HStack(spacing: 12) {
            // Participant Image
            ProfilePhotoView(imageUrl: otherParticipantPhotoUrl)
                 .frame(width: 80, height: 80)
                 .clipShape(RoundedRectangle(cornerRadius: 12))

            // Booking Details Text
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.serviceCategoryName) // e.g., "Appliance Repair"
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(ServxTheme.primaryColor) // Use theme

                Text(otherParticipantName) // e.g., "Alex Nguyen"
                    .font(.caption)
                    .foregroundColor(ServxTheme.secondaryTextColor) // Use theme
                
                // Display Time and Status Badge
                HStack(spacing: 6) {
                    Text(formattedTime)
                        .font(.caption)
                        .foregroundColor(ServxTheme.secondaryTextColor)
                    
                    // Status Badge (customize appearance as needed)
                    let uiTab = booking.status.displayTab
                    Text(uiTab.rawValue) // "Upcoming", "Completed", "Cancelled"
                         .font(.caption2.weight(.medium))
                         .padding(.horizontal, 8)
                         .padding(.vertical, 3)
                         .foregroundColor(statusForegroundColor(booking.status))
                         .background(statusBackgroundColor(booking.status).opacity(0.15))
                         .clipShape(Capsule())
                }
            }

            Spacer() // Pushes message button to the right

            // Message Button
            Button {
                // Action: Navigate to chat using the serviceRequestId
                navigator.navigateToChat(requestId: booking.serviceRequestId)
            } label: {
                Image(systemName: "message.fill")
                    .font(.title2)
                    .foregroundColor(ServxTheme.primaryColor)
            }
            .buttonStyle(.plain) // Remove default button background/border

        } //: HStack
        .padding() // Padding around the card content
        .background(Color(.secondarySystemBackground)) // Card background
        .cornerRadius(16)
        // Optional: Add shadow like BookingCardView if desired
        // .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // Helper functions for status badge styling (customize colors)
    private func statusBackgroundColor(_ status: BookingStatus) -> Color {
         switch status.displayTab {
         case .upcoming: return .blue
         case .completed: return .green
         case .cancelled: return .red
         }
     }

     private func statusForegroundColor(_ status: BookingStatus) -> Color {
         switch status.displayTab {
          case .upcoming: return .blue
          case .completed: return .green
          case .cancelled: return .red
          }
      }
}
