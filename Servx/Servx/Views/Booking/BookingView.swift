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
    @EnvironmentObject private var navigator: NavigationManager

    init(viewModel: BookingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomTabBar(selectedTab: $viewModel.selectedTab)
                .padding(.horizontal)
                .padding(.top)

            bookingListContent()
                .overlay(alignment: .top) {
                    if let successMsg = viewModel.successMessage {
                        SuccessBanner(message: successMsg)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .onAppear {
                                // Banner handles its own dismissal
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                }
        }
        .navigationTitle("My Bookings")
        .navigationBarTitleDisplayMode(.inline)
        .background(ServxTheme.backgroundColor.ignoresSafeArea())
        .task {
            if viewModel.bookings.isEmpty {
                print("BookingView: Bookings list is empty. Fetching data...")
                await viewModel.fetchBookings(page: 0)
            } else {
                print("BookingView: Bookings list already contains data. No need to fetch.")
            }
        }
        .refreshable {
            print("BookingView: Initiating refresh action.")
            await viewModel.resetAndFetchCurrentTab()
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { show in if !show { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        .onChange(of: viewModel.chatNavigationTarget) { _, newTargetId in
            handleChatNavigation(targetId: newTargetId)
        }
        .animation(.default, value: viewModel.successMessage)
    }

    @ViewBuilder
    private func bookingListContent() -> some View {
        ZStack {
            if viewModel.isLoading && viewModel.bookings.isEmpty {
                VStack {
                    Spacer()
                    ProgressView("Loading Bookings...")
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.isLoading && viewModel.bookings.isEmpty && viewModel.errorMessage == nil {
                VStack {
                    Spacer()
                    Text("You have no \(viewModel.selectedTab.rawValue.lowercased()) bookings.")
                        .foregroundColor(ServxTheme.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.bookings) { booking in
                        BookingCardViewWrapper(booking: booking, viewModel: viewModel)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .onAppear {
                                if booking.id == viewModel.bookings.last?.id && !viewModel.isLoading {
                                    Task {
                                        print("BookingView: Last item \(booking.id) appeared, loading more bookings...")
                                        await viewModel.loadMoreBookings()
                                    }
                                }
                            }
                    }

                    if viewModel.isLoading && !viewModel.bookings.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding(.vertical)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .background(ServxTheme.backgroundColor)
                .scrollContentBackground(.hidden)
            }

            if !viewModel.isLoading && viewModel.bookings.isEmpty && viewModel.errorMessage != nil {
                VStack {
                    Spacer()
                    Text("⚠️ \(viewModel.errorMessage!)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func handleChatNavigation(targetId: Int64?) {
        guard let requestId = targetId else { return }
        print("BookingView: Navigating to chat for request ID \(requestId).")
        navigator.navigateToChat(requestId: requestId)
        viewModel.didNavigateToChat()
    }
}

struct BookingCardViewWrapper: View {
    let booking: Booking
    @ObservedObject var viewModel: BookingViewModel

    var body: some View {
        BookingCardView(booking: booking, viewModel: viewModel)
    }
}

struct SuccessBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
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

    // Map State
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
        VStack(alignment: .leading, spacing: 12) {
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
                Map(position: $mapCameraPosition) {
                    if let coordinate = bookingCoordinate {
                        Marker(booking.serviceName, coordinate: coordinate)
                            .tint(ServxTheme.primaryColor)
                    }
                }
                .frame(height: 150)
                .cornerRadius(10)
                .padding(.top, 5)

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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(ServxTheme.primaryColor)
                .padding(.top, 5)

            } else {
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

            actionButtons()
                .padding(.top, 5)

        }
        .padding(.horizontal)
        .padding(.bottom)
        .task {
            await geocodeAddressAndSetupMap()
        }
        .alert("Confirm Cancellation", isPresented: $showCancelConfirmAlert) {
            Button("Cancel Booking", role: .destructive) {
                Task { await viewModel.cancelBooking(bookingId: booking.id) }
            }
            Button("Never Mind", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this booking?")
        }
    }

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

    @ViewBuilder
    private func actionButtons() -> some View {

        var currentUserRole: Role? { viewModel.currentRole }

        let _ = print("bookingIssue: [DetailsView Actions \(booking.id)] Evaluating. Status: \(booking.status), ProviderMarked: \(booking.providerMarkedComplete), Role: \(currentUserRole?.rawValue ?? "nil")")
        
        VStack(spacing: 10) {
            if booking.status == .upcoming {
                if currentUserRole == .serviceProvider
                    && !booking.providerMarkedComplete
                {
                    Button {
                        Task {
                            await viewModel.providerMarkComplete(
                                bookingId: booking.id
                            )
                        }
                    } label: {
                        Label(
                            "Mark as Completed",
                            systemImage: "checkmark.circle.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ServxTheme.primaryColor)
                }
                else if currentUserRole == .serviceSeeker
                    && booking.providerMarkedComplete
                {
                    Button {
                        Task {
                            await viewModel.seekerConfirmCompletion(
                                bookingId: booking.id
                            )
                        }
                    } label: {
                        Label(
                            "Confirm Completion",
                            systemImage: "checkmark.seal.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                else if currentUserRole == .serviceSeeker
                    && !booking.providerMarkedComplete
                {
                    Text("Waiting for provider to mark as complete.")
                        .font(.footnote)
                        .foregroundColor(ServxTheme.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 5)
                }

                Button {
                    showCancelConfirmAlert = true
                } label: {
                    Text("Cancel Booking")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)

            } else if booking.status == .completed {
                
                Button {
                    viewModel.viewEReceipt(booking: booking)
                } label: {
                    Text("View e-Receipt")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(ServxTheme.primaryColor)

            } else if booking.status == .cancelledByProvider
                || booking.status == .cancelledBySeeker
            {
                Text("Booking Cancelled")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 5)
            }
        }
    }

    private struct IdentifiableCoordinate: Identifiable {
        let id = UUID()
        let coord: CLLocationCoordinate2D
    }

    @MainActor
    private func geocodeAddressAndSetupMap() async {
        print(
            "BookingCardDetailsView: Attempting to geocode address: \(fullAddress)"
        )
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(
                fullAddress
            )
            if let coordinate = placemarks.first?.location?.coordinate {
                print(
                    "BookingCardDetailsView: Geocoding successful - Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)"
                )
                self.bookingCoordinate = coordinate
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
                self.bookingCoordinate = nil
            }
        } catch {
            print(
                "BookingCardDetailsView: Geocoding failed for address '\(fullAddress)': \(error)"
            )
            self.bookingCoordinate = nil
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
    let booking: Booking
    @ObservedObject var viewModel: BookingViewModel
    @EnvironmentObject var navigator: NavigationManager

    @State private var showDetails = false

    private var otherParticipant: (name: String, photoUrl: URL?) {
        viewModel.getOtherParticipant(for: booking)
    }

    private var participantImageURL: URL? {
        let url: URL? = otherParticipant.photoUrl
        print(
            "photoIssue123: [BookingCardView \(booking.id)] participantImageURL returning: \(url?.absoluteString ?? "nil")"
        )
        return url
    }

    var body: some View {

        let _ = print("bookingIssue: [BookingCardView body \(booking.id)] Evaluating. Status: \(booking.status), ProviderMarked: \(booking.providerMarkedComplete)")


        VStack(spacing: 0) {
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

                    Text(otherParticipant.name)
                        .font(.subheadline)
                        .foregroundColor(ServxTheme.secondaryTextColor)
                        .padding(.bottom, 4)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
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
                Spacer()
            }
            .padding([.top, .leading, .trailing])
            .padding(.bottom, 10)

            Divider()

            // MARK: Collapsible Details Section
            if showDetails {
                BookingCardDetailsView(booking: booking, viewModel: viewModel)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // MARK: Action Buttons Row
            actionButtons()
                .padding(.vertical, 10)
                .padding(.horizontal)

        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }

    // MARK: Action Buttons
    @ViewBuilder
    private func actionButtons() -> some View {
        
        let _ = print("bookingIssue: [BookingCardView Actions \(booking.id)] Evaluating. Status: \(booking.status)")
        
        HStack(spacing: 10) {
            Spacer()

            Button {
                withAnimation {
                    showDetails.toggle()
                }
            } label: {
                Text(showDetails ? "Hide Details" : "View Details")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16)
                    .frame(height: 36)
            }
            .buttonStyle(.bordered)
            .tint(ServxTheme.primaryColor)

            switch booking.status {
            case .upcoming:
                Button {
                    viewModel.messageUser(booking: booking)
                } label: {
                    Text("Message")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(ServxTheme.primaryColor)

            case .completed:
                if viewModel.currentRole == .serviceSeeker {
                    Button {
                        print(
                            "Navigate to Leave Review for booking \(booking.id)"
                        )
                        navigator.navigate(to: AppRoute.BookingTab.leaveReview(
                                        bookingId: booking.id,
                                        providerName: booking.providerFullName,
                                        serviceName: booking.serviceName
                                    ))
                    } label: {
                        Label("Leave Review", systemImage: "star.fill")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ServxTheme.primaryColor)
                } else {
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
