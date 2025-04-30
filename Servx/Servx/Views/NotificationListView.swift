//
//  NotificationListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI

struct NotificationListView: View {
    @StateObject private var viewModel = NotificationViewModel()
    @EnvironmentObject private var navigator: NavigationManager
    private let router = NotificationRouter()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.notifications.isEmpty {
                EmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(notification: notification)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // 1. Mark As Read
                                if !notification.isRead {
                                    Task {
                                        // Call ViewModel's function
                                        await viewModel.markAsRead(
                                            notification.id
                                        )
                                    }
                                }
                                // 2. Navigate via Router
                                router.handleNavigation(
                                    for: notification,
                                    navigator: navigator
                                )
                            }
                            .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.loadNotifications()
                }
            }
        }
        .navigationTitle("Notifications")
        .task {
            if viewModel.notifications.isEmpty {
                await viewModel.loadNotifications()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
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
    let notification: Notification

    // Date parsing helper
    private var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        if let date = formatter.date(from: notification.createdAt) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: notification.createdAt)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName(for: notification.type))
                .font(.title3)
                .foregroundColor(iconColor(for: notification.type))
                .frame(width: 30)

            // Main content
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.formattedTitle())
                    .font(.headline)
                    .lineLimit(1)
                    .opacity(notification.isRead ? 0.7 : 1.0)

                Text(notification.formattedMessage())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .opacity(notification.isRead ? 0.7 : 1.0)

                HStack {
                    if let date = date {
                        Text(date, style: .relative)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .padding(.trailing, 5)
            }

        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }

    private func iconName(for type: Notification.NotificationType) -> String {
        switch type {
        case .newRequest: return "bell.badge.fill"
        case .requestAccepted: return "checkmark.circle.fill"
        case .requestDeclined: return "xmark.circle.fill"
        case .bookingConfirmed: return "calendar.badge.checkmark"
        case .bookingCancelled: return "xmark.circle.fill"
        case .systemAlert: return "exclamationmark.triangle.fill"
        case .providerMarkedComplete: return "checkmark.circle.fill"
        case .seekerConfirmedCompletion: return "checkmark.circle.fill"
        }
    }

    private func iconColor(for type: Notification.NotificationType) -> Color {
        switch type {
        case .newRequest: return .blue
        case .requestAccepted: return .green
        case .requestDeclined: return .red
        case .bookingConfirmed: return .purple
        case .bookingCancelled: return .red
        case .systemAlert: return .yellow
        case .providerMarkedComplete: return .green
        case .seekerConfirmedCompletion: return .green
        }
    }
}
