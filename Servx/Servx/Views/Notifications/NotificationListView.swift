//
//  NotificationListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI

struct NotificationListView: View {
    @StateObject var viewModel: NotificationViewModel
    private let router = NotificationRouter()
    @EnvironmentObject private var navigator: NavigationManager

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.notifications.isEmpty {
                EmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(
                            notification: notification,
                            router: router
                        )
                    }
                }
                .refreshable { await viewModel.loadNotifications() }
            }
        }
        .navigationTitle("Notifications")
        .task { await viewModel.loadNotifications() }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Empty State
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

struct NotificationRow: View {
    let notification: Notification
    let router: NotificationRouterProtocol
    @EnvironmentObject private var navigator: NavigationManager
    
    private var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: notification.createdAt)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.formattedTitle())
                    .font(.headline)
                
                Text(notification.formattedMessage())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    if let date = date {
                        Text(date, style: .relative)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                Task { @MainActor in
                    router.handleNavigation(for: notification, navigator: navigator)
                }
            }
        }
    }
}
