//
//  CalendarView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @EnvironmentObject private var navigator: NavigationManager

    var body: some View {
        VStack(spacing: 0) {
            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.horizontal)
            .tint(ServxTheme.primaryColor)
            .onChange(of: viewModel.selectedDate) {
                print("CalendarView: Date selected: \(viewModel.selectedDate)")
            }


            bookingListHeader()
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 10)

            Divider()
                .padding(.horizontal)


            bookingListContent()

            Spacer()
        }
        .navigationTitle("My Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .background(ServxTheme.backgroundColor.ignoresSafeArea())
        .task {
            await viewModel.fetchBookings(for: viewModel.selectedDate)
        }
        .refreshable {
            await viewModel.fetchBookings(for: viewModel.selectedDate)
        }
        .alert("Error Loading Bookings", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _,_ in viewModel.errorMessage = nil }
        )) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "Could not load calendar data.")
        }
    }

    @ViewBuilder
    private func bookingListHeader() -> some View {
        HStack {
            Text(viewModel.serviceBookingCountText)
                .font(.title3.weight(.semibold))
                .foregroundColor(ServxTheme.primaryColor)

            Spacer()

            Button("See All") {
                navigator.switchTab(to: .booking)
            }
            .font(.callout)
            .foregroundColor(ServxTheme.primaryColor)
        }
    }

    @ViewBuilder
    private func bookingListContent() -> some View {
        if viewModel.isLoading && viewModel.bookingsForSelectedDate.isEmpty {
            ProgressView()
                .padding(.top, 50)
        } else if viewModel.bookingsForSelectedDate.isEmpty {
            VStack(spacing: 10) {
                 Image(systemName: "calendar.badge.exclamationmark")
                     .font(.largeTitle)
                     .foregroundColor(.gray)
                 Text("You have no service booking")
                 Text("You don't have a service booking on this date")
                     .font(.subheadline)
                     .foregroundColor(ServxTheme.secondaryTextColor)
             }
             .padding(.top, 50)
             .frame(maxWidth: .infinity)

        } else {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.bookingsForSelectedDate) { booking in
                        CalendarBookingCardView(booking: booking)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
                .padding(.bottom)
            }
        }
    }
}


struct CalendarBookingCardView: View {
    let booking: Booking
    @EnvironmentObject private var navigator: NavigationManager
    private let currentUserRole: Role? = AuthenticatedUser.shared.currentUser?.role

    private var otherParticipantName: String {
        guard let role = currentUserRole else { return "Unknown User" }
        return role == .serviceProvider ? booking.seekerFullName : booking.providerFullName
    }

    private var otherParticipantPhotoUrl: URL? {
        guard let role = currentUserRole else { return nil }
            let photoURL: URL? = role == .serviceProvider ? booking.seekerProfilePhotoUrl : booking.providerProfilePhotoUrl
            return photoURL
     }
     
     private var formattedTime: String {
         booking.scheduledStartDate?.formatted(date: .omitted, time: .shortened) ?? "--:--"
     }

    var body: some View {
        HStack(spacing: 12) {
            ProfilePhotoView(imageUrl: otherParticipantPhotoUrl)
                 .frame(width: 80, height: 80)
                 .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(booking.serviceCategoryName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(ServxTheme.primaryColor)

                Text(otherParticipantName)
                    .font(.caption)
                    .foregroundColor(ServxTheme.secondaryTextColor)
                
                HStack(spacing: 6) {
                    Text(formattedTime)
                        .font(.caption)
                        .foregroundColor(ServxTheme.secondaryTextColor)
                    
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

            Spacer()

            Button {
                navigator.navigateToChat(requestId: booking.serviceRequestId)
            } label: {
                Image(systemName: "message.fill")
                    .font(.title2)
                    .foregroundColor(ServxTheme.primaryColor)
            }
            .buttonStyle(.plain)

        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
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
