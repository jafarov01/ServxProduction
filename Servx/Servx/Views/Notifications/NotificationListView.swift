//
//  NotificationListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI

struct NotificationListView: View {
    // Use @StateObject: View creates and owns the ViewModel
    @StateObject private var viewModel = NotificationViewModel()
    @EnvironmentObject private var navigator: NavigationManager // For navigation actions
    private let router = NotificationRouter() // Router instance

    var body: some View {
        Group {
            // Loading state
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Empty state
            } else if viewModel.notifications.isEmpty {
                EmptyStateView()  // Your empty state view
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                // List of notifications
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        // NotificationRow is now just for display
                        NotificationRow(notification: notification)
                            .contentShape(Rectangle())  // Make the whole row area tappable
                            .onTapGesture {
                                // --- Handle Tap Actions Here in the List View ---
                                // 1. Mark As Read (only if needed)
                                if !notification.isRead {
                                    Task {
                                        // Call ViewModel's function
                                        await viewModel.markAsRead(
                                            notification.id
                                        )
                                    }
                                }
                                // 2. Navigate via Router (always allow tap)
                                router.handleNavigation(
                                    for: notification,
                                    navigator: navigator
                                )
                                // --- End Tap Actions ---
                            }
                            .listRowInsets(EdgeInsets())  // Optional: Adjust row padding if needed
                    }
                }
                .listStyle(.plain)  // Use plain style to remove default row separators/insets if desired
                .refreshable {  // Pull-to-refresh action
                    await viewModel.loadNotifications()
                }
            }
        }
        .navigationTitle("Notifications")  // Assuming used within a NavigationStack
        .task {  // Load data when view first appears
            if viewModel.notifications.isEmpty {
                await viewModel.loadNotifications()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {  // Error handling
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Empty State (Keep your existing implementation)
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No Notifications")
                .font(.title2)
                .foregroundColor(.primary)
            Text("You'll see important updates here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
}

// Represents a single row - purely display logic
struct NotificationRow: View {
    let notification: Notification  // Only needs the data to display

    // Date parsing helper
    private var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        if let date = formatter.date(from: notification.createdAt) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]  // Fallback
        return formatter.date(from: notification.createdAt)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {  // Add spacing
            // Optional: Add an icon based on notification type
            Image(systemName: iconName(for: notification.type))
                .font(.title3)
                .foregroundColor(iconColor(for: notification.type))
                .frame(width: 30)  // Align icons

            // Main content
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.formattedTitle())
                    .font(.headline)
                    .lineLimit(1)
                    // Dim if read
                    .opacity(notification.isRead ? 0.7 : 1.0)

                Text(notification.formattedMessage())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)  // Allow slightly more text
                    .opacity(notification.isRead ? 0.7 : 1.0)

                HStack {
                    if let date = date {
                        Text(date, style: .relative)  // Relative time is good here
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()  // Push dot to the right if needed, or remove if icon used
                }
            }

            Spacer()  // Push content left

            // Blue dot indicator for unread
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)  // Use theme color if available
                    .frame(width: 8, height: 8)
                    .padding(.trailing, 5)  // Add padding to dot
            }

        }
        .padding(.vertical, 10)  // Vertical padding for the row
        .padding(.horizontal)  // Horizontal padding for the row
        // Removed onTapGesture - it's handled by the ListView
    }

    // Helper for icon based on type (example)
    private func iconName(for type: Notification.NotificationType) -> String {
        switch type {
        case .newRequest: return "bell.badge.fill"
        case .requestAccepted: return "checkmark.circle.fill"
        case .requestDeclined: return "xmark.circle.fill"
        case .bookingConfirmed: return "calendar.badge.checkmark"
        case .serviceCompleted: return "star.fill"
        case .systemAlert: return "exclamationmark.triangle.fill"
        }
    }

    // Helper for icon color (example)
    private func iconColor(for type: Notification.NotificationType) -> Color {
        switch type {
        case .newRequest: return .blue
        case .requestAccepted: return .green
        case .requestDeclined: return .red
        case .bookingConfirmed: return .purple
        case .serviceCompleted: return .orange
        case .systemAlert: return .yellow
        }
    }
}
