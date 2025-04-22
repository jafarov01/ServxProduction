//
//  BookingView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import CoreLocation
import MapKit
import SwiftUI

struct BookingView: View {
    @ObservedObject private var viewModel: BookingViewModel
    // Access the shared NavigationManager from the environment
    @EnvironmentObject private var navigator: NavigationManager

    init(viewModel: BookingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {  // Use VStack with no spacing for tight control
            // Top Custom Tab Bar
            CustomTabBar(selectedTab: $viewModel.selectedTab)
                .padding(.horizontal)  // Add horizontal padding if needed
                .padding(.top)  // Add top padding if needed

            // Content Area for the list
            bookingListContent()
        }
        .navigationTitle("My Bookings")
        .navigationBarTitleDisplayMode(.inline)  // Or .large
        .background(ServxTheme.backgroundColor.ignoresSafeArea())  // Background for the whole screen
        .task {  // Use .task for initial data load when the view appears
            // Fetch only if the list is currently empty for the default selected tab
            if viewModel.bookings.isEmpty {
                await viewModel.fetchBookings(initialLoad: true)
            }
        }
        .refreshable {  // Enable pull-to-refresh
            await viewModel.fetchBookings(initialLoad: true)  // Reload current tab
        }
        // Display alerts based on ViewModel's error message
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _, _ in viewModel.errorMessage = nil }  // Clear error on dismiss
            )
        ) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        // *** Observer for Navigation Signal from ViewModel ***
        .onChange(of: viewModel.chatNavigationTarget) { _, newTargetId in
            handleChatNavigation(targetId: newTargetId)
        }
    }

    // Builds the main content area (List, Loading, Empty, Error)
    @ViewBuilder
    private func bookingListContent() -> some View {
        // Remove the outer Group
        if viewModel.isLoading && viewModel.bookings.isEmpty {
            // Loading state for initial fetch
            VStack {  // Wrap in VStack to center ProgressView
                Spacer()
                ProgressView("Loading Bookings...")
                Spacer()
            }
            // Apply frame to the VStack to fill space
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if !viewModel.isLoading && viewModel.bookings.isEmpty
            && viewModel.errorMessage == nil
        {
            // Empty state
            VStack {  // Wrap in VStack to center Text
                Spacer()
                Text(
                    "You have no \(viewModel.selectedTab.rawValue.lowercased()) bookings."
                )
                .foregroundColor(ServxTheme.secondaryTextColor)  // Use your theme
                .multilineTextAlignment(.center)
                .padding()
                Spacer()
            }
            // Apply frame to the VStack to fill space
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            // List view for bookings or error display
            // List itself usually expands, frame might not be needed here,
            // or apply it if necessary for specific layout control.
            List {
                // Display error message if applicable
                if let errorMsg = viewModel.errorMessage, !viewModel.isLoading {
                    Section {
                        Text("⚠️ \(errorMsg)")
                            .foregroundColor(.red)
                            .padding(.vertical)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                ForEach(viewModel.bookings) { booking in
                    BookingCardView(booking: booking, viewModel: viewModel)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 8)
                        .padding(.horizontal)  // Add horizontal padding *here*
                        .onAppear {
                            // Pagination trigger logic
                            let canLoad =
                                viewModel.canLoadMore[viewModel.selectedTab]
                                ?? false
                            if booking.id == viewModel.bookings.last?.id
                                && canLoad && !viewModel.isLoading
                            {
                                Task {
                                    await viewModel.loadMoreBookings()
                                }
                            }
                        }
                }  //: ForEach

                // Loading indicator at the bottom for pagination
                if viewModel.isLoading && !viewModel.bookings.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding(.vertical)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
            }  //: List
            .listStyle(.plain)
            .background(ServxTheme.backgroundColor)  // Apply background to List
            .scrollContentBackground(.hidden)  // Apply to List
            // .frame(maxWidth: .infinity, maxHeight: .infinity) // Apply frame to List if needed
        }
    }

    // Handles navigation trigger from ViewModel
    private func handleChatNavigation(targetId: Int64?) {
        guard let requestId = targetId else { return }

        print(
            "BookingView: Reacting to chatNavigationTarget change, navigating to \(requestId)"
        )
        navigator.navigateToChat(requestId: requestId)  // Use environment navigator

        // Reset the target in the ViewModel AFTER triggering navigation
        DispatchQueue.main.async {
            viewModel.chatNavigationTarget = nil
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: DisplayTab

    let tabs = DisplayTab.allCases

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Spacer()

                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.headline)
                            .fontWeight(
                                selectedTab == tab ? .semibold : .regular
                            )
                            .foregroundColor(
                                selectedTab == tab
                                    ? ServxTheme.primaryColor
                                    : ServxTheme.secondaryTextColor
                            )

                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(
                                selectedTab == tab
                                    ? ServxTheme.primaryColor : .clear
                            )
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
        }
        .frame(height: 50)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .bottom)
    }
}

struct BookingCardDetailsView: View {
    let booking: Booking
    @ObservedObject var viewModel: BookingViewModel

    // Map State (Modern API)
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var bookingCoordinate: CLLocationCoordinate2D? = nil

    // Alert State
    @State private var showCancelConfirmAlert = false

    // Helper to format the full address string for display and geocoding
    private var fullAddress: String {
        let components = [
            booking.locationAddressLine,
            booking.locationCity,
            booking.locationZipCode,
            booking.locationCountry,
        ]
        return components.filter { !$0.isEmpty }.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {  // Use consistent spacing
            Divider().padding(.bottom, 5)

            detailRow(label: "Booking No:", value: booking.bookingNumber)
            detailRow(
                label: "Date:",
                value: booking.scheduledStartDate?.formatted(
                    date: .long,
                    time: .omitted
                ) ?? "-"
            )
            detailRow(
                label: "Time:",
                value: booking.scheduledStartDate?.formatted(
                    date: .omitted,
                    time: .shortened
                ) ?? "-"
            )
            detailRow(
                label: "Est. Duration:",
                value: "\(booking.durationMinutes) minutes"
            )
            detailRow(
                label: "Est. Price:",
                value: formattedPriceRange(
                    min: booking.priceMin,
                    max: booking.priceMax
                )
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("Location:")
                    .font(.subheadline).bold()
                    .foregroundColor(ServxTheme.secondaryTextColor)
                Text(fullAddress)
                    .font(.subheadline)
                    .foregroundColor(ServxTheme.secondaryTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let notes = booking.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notes:")
                        .font(.subheadline).bold()
                        .foregroundColor(ServxTheme.secondaryTextColor)
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(ServxTheme.secondaryTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // --- Map Section ---
            if bookingCoordinate != nil {
                // Use modern Map initializer
                Map(position: $mapCameraPosition) {
                    // Use Marker for annotation if coordinate exists
                    if let coordinate = bookingCoordinate {
                        Marker(booking.serviceName, coordinate: coordinate)
                            .tint(ServxTheme.primaryColor)
                    }
                }
                .frame(height: 150)
                .cornerRadius(10)
                .padding(.top, 5)

                // Get Directions Button (Standard SwiftUI Button)
                Button {
                    if let coordinate = bookingCoordinate {
                        openAppleMapsForDirections(
                            coordinate: coordinate,
                            name: booking.serviceName
                        )
                    }
                } label: {
                    Label(
                        "Get Directions",
                        systemImage: "arrow.triangle.turn.up.right.diamond.fill"
                    )
                    .frame(maxWidth: .infinity)  // Make label take width
                    .padding(.vertical, 10)  // Adjust padding
                }
                .buttonStyle(.borderedProminent)  // Use a standard prominent style
                .tint(ServxTheme.primaryColor)  // Apply theme color
                .padding(.top, 5)

            } else {
                // Displayed if geocoding is pending or failed
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "map.circle")
                            .foregroundColor(.gray)
                        Text("Map location unavailable or still loading.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            // --- End Map Section ---

            // Action buttons specific to the details view
            actionButtons()
                .padding(.top, 5)

        }  //: VStack
        .padding(.horizontal)
        .padding(.bottom)
        .task {  // Use .task to perform async work when view appears
            await geocodeAddressAndSetupMap()
        }
        // Confirmation Alert for Cancellation
        .alert("Confirm Cancellation", isPresented: $showCancelConfirmAlert) {
            Button("Cancel Booking", role: .destructive) {
                Task { await viewModel.cancelBooking(bookingId: booking.id) }
            }
            Button("Never Mind", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this booking?")
        }
    }

    // Helper for consistent detail rows
    @ViewBuilder
    private func detailRow(
        label: String,
        value: String,
        valueLineLimit: Int? = 1
    ) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline).bold()
                .foregroundColor(ServxTheme.secondaryTextColor)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(ServxTheme.primaryColor)
                .lineLimit(valueLineLimit)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // Detail-specific action buttons
    @ViewBuilder
    private func actionButtons() -> some View {
        VStack(spacing: 10) {
            if booking.status == .upcoming {
                Button {
                    showCancelConfirmAlert = true  // Show confirmation alert
                } label: {
                    Text("Cancel Booking")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)  // Use bordered style for less emphasis than primary
                .tint(.red)  // Tint indicates destructive potential

            } else if booking.status == .completed {
                Button {
                    viewModel.viewEReceipt(booking: booking)
                } label: {
                    Text("View e-Receipt")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(ServxTheme.primaryColor)

                // TODO: Add Leave Review Button (conditionally)
            }
        }
    }

    // --- Geocoding & MapKit Helpers ---
    private struct IdentifiableCoordinate: Identifiable {
        let id = UUID()
        let coord: CLLocationCoordinate2D
    }

    // Renamed function to clarify it does both
    @MainActor  // Ensure state updates happen on main thread
    private func geocodeAddressAndSetupMap() async {
        print(
            "BookingCardDetailsView: Attempting to geocode address: \(fullAddress)"
        )
        let geocoder = CLGeocoder()
        do {
            // Attempt geocoding
            let placemarks = try await geocoder.geocodeAddressString(
                fullAddress
            )
            if let coordinate = placemarks.first?.location?.coordinate {
                print(
                    "BookingCardDetailsView: Geocoding successful - Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)"
                )
                self.bookingCoordinate = coordinate
                // Set map camera position centered on the coordinate
                self.mapCameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.02,
                            longitudeDelta: 0.02
                        )  // Adjust zoom
                    )
                )
            } else {
                print(
                    "BookingCardDetailsView: Geocoding returned no location for address."
                )
                self.bookingCoordinate = nil  // Ensure it's nil if geocoding fails
            }
        } catch {
            print(
                "BookingCardDetailsView: Geocoding failed for address '\(fullAddress)': \(error)"
            )
            self.bookingCoordinate = nil  // Ensure it's nil on error
        }
    }

    private func openAppleMapsForDirections(
        coordinate: CLLocationCoordinate2D,
        name: String?
    ) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name ?? "Booking Location"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey:
                MKLaunchOptionsDirectionsModeDriving
        ])
    }

    // --- Price Formatting ---
    private func formattedPriceRange(min: Double?, max: Double?) -> String {
        let minPrice = min ?? 0.0
        let maxPrice = max ?? minPrice
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let minStr =
            formatter.string(from: NSNumber(value: minPrice)) ?? "\(minPrice)"
        if abs(minPrice - maxPrice) < 0.01 {
            return minStr
        } else {
            let maxStr =
                formatter.string(from: NSNumber(value: maxPrice))
                ?? "\(maxPrice)"
            return "\(minStr) - \(maxStr)"
        }
    }
}

struct BookingCardView: View {
    let booking: Booking  // Use the Booking domain model
    // Use @ObservedObject since the ViewModel lifecycle is managed by BookingView
    @ObservedObject var viewModel: BookingViewModel

    // State to control the expansion of details
    @State private var showDetails = false

    private var otherParticipant: (name: String, photoUrl: URL?) {
        viewModel.getOtherParticipant(for: booking)
    }

    // Corrected computed property - simply return the URL? from the helper
    private var participantImageURL: URL? {
        let url: URL? = otherParticipant.photoUrl  // Get the URL?
        // Optional debug print
        print(
            "photoIssue123: [BookingCardView \(booking.id)] participantImageURL returning: \(url?.absoluteString ?? "nil")"
        )
        return url  // Return it directly
    }

    var body: some View {

        let _ = print(
            "photoIssue123: [BookingCardView \(booking.id)] Passing to ProfilePhotoView: \(participantImageURL?.absoluteString ?? "nil")"
        )

        VStack(spacing: 0) {  // Use spacing 0 for tight layout control
            // MARK: Card Header (Image & Summary Text)
            HStack(alignment: .top, spacing: 12) {
                ProfilePhotoView(imageUrl: participantImageURL)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.serviceCategoryName)
                        .font(.caption)
                        .foregroundColor(ServxTheme.secondaryTextColor)

                    Text(booking.serviceName)
                        .font(.headline)
                        .foregroundColor(ServxTheme.primaryColor)
                        .lineLimit(1)

                    Text(otherParticipant.name)  // Show Provider or Seeker name
                        .font(.subheadline)
                        .foregroundColor(ServxTheme.secondaryTextColor)
                        .padding(.bottom, 4)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        // More concise date format for the card view
                        Text(
                            booking.scheduledStartDate?.formatted(
                                date: .abbreviated,
                                time: .omitted
                            ) ?? "No Date"
                        )
                    }
                    .font(.caption)
                    .foregroundColor(ServxTheme.secondaryTextColor)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text(
                            booking.scheduledStartDate?.formatted(
                                date: .omitted,
                                time: .shortened
                            ) ?? "No Time"
                        )
                    }
                    .font(.caption)
                    .foregroundColor(ServxTheme.secondaryTextColor)
                }
                Spacer()  // Push content to left
            }
            .padding([.top, .leading, .trailing])  // Padding around top content
            .padding(.bottom, 10)

            Divider()

            // MARK: Collapsible Details Section
            // Animate the appearance/disappearance of the details
            if showDetails {
                BookingCardDetailsView(booking: booking, viewModel: viewModel)
                    .transition(.opacity.combined(with: .move(edge: .top)))  // Add animation
            }

            // MARK: Action Buttons Row
            actionButtons()
                .padding(.vertical, 10)
                .padding(.horizontal)

        }  //: Main VStack
        .background(Color(.secondarySystemBackground))  // Card background
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)  // Subtle shadow
    }

    // MARK: Action Buttons
    @ViewBuilder
    private func actionButtons() -> some View {
        HStack(spacing: 10) {
            Spacer()

            Button {
                withAnimation {  // Animate the details toggle
                    showDetails.toggle()
                }
            } label: {
                Text(showDetails ? "Hide Details" : "View Details")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16)
                    .frame(height: 36)
            }
            .buttonStyle(.bordered)  // Use bordered style for secondary action
            .tint(ServxTheme.primaryColor)

            // Primary action button changes based on status
            switch booking.status {
            case .upcoming:
                Button {
                    viewModel.messageUser(booking: booking)
                } label: {
                    Label("Message", systemImage: "message.fill")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)  // Use prominent style for primary action
                .tint(ServxTheme.primaryColor)

            case .completed:
                Button {
                    viewModel.bookAgain(booking: booking)
                } label: {
                    Label("Book Again", systemImage: "arrow.clockwise")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(ServxTheme.primaryColor)

            case .cancelledBySeeker, .cancelledByProvider:
                Button {
                    viewModel.bookAgain(booking: booking)
                } label: {
                    Label("Book Again", systemImage: "arrow.clockwise")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(ServxTheme.primaryColor)
            }
            Spacer()
        }
    }
}
