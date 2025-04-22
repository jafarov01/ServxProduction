//
//  InboxView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()
    @EnvironmentObject private var navigator: NavigationManager // Access navigator

    var body: some View {
        Group { // Use Group instead of NavigationView assuming embedded in NavStack
            if viewModel.isLoading && viewModel.conversations.isEmpty {
                ProgressView("Loading Chats...")
            } else if !viewModel.conversations.isEmpty {
                List {
                    ForEach(viewModel.conversations) { conversation in
                        // Row is tappable, triggers ViewModel action
                         InboxRowView(conversation: conversation)
                            .contentShape(Rectangle()) // Make whole area tappable
                            .onTapGesture {
                                viewModel.selectConversation(requestId: conversation.id)
                            }
                            .buttonStyle(PlainButtonStyle()) // Optional: remove default button styling
                    }
                }
                .listStyle(.plain)
                .refreshable { await viewModel.loadConversations() } // Pull-to-refresh
                // Reacts to ViewModel's selection change and navigates
                .onChange(of: viewModel.selectedRequestId) { _, newRequestId in
                    if let requestId = newRequestId {
                        print("InboxView: Navigating via manager to chat: \(requestId)")
                        navigator.inboxStack.append(AppRoute.Inbox.chat(requestId: requestId))
                        viewModel.selectedRequestId = nil
                    }
                }
            } else {
                // Empty state
                Text("No conversations yet.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Inbox")
        .task { // Load data when view appears
            if viewModel.conversations.isEmpty {
                await viewModel.loadConversations()
            }
        }
        .alert("Error", isPresented: Binding( // Error alert
            get: { viewModel.errorMessage != nil },
            set: { _,_ in viewModel.errorMessage = nil }
        )) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        // .navigationDestination is handled in MainTabView for AppRoute.Inbox
    }
}

// Represents a single row in the Inbox list
struct InboxRowView: View {
    let conversation: ChatConversationDTO

    var body: some View {
        HStack {
            // Left side: Name and Last Message
            VStack(alignment: .leading, spacing: 4) {
                ServxTextView(
                    text: conversation.otherParticipantName,
                    // Bold if unread
                    size: 16, weight: conversation.unreadCount > 0 ? .semibold : .regular
                )

                ServxTextView(
                    text: conversation.lastMessage ?? "...",
                    color: .gray,
                    size: 14,
                    lineLimit: 1
                )
                // Bold if unread
                .fontWeight(conversation.unreadCount > 0 ? .semibold : .regular)
            }

            Spacer() // Pushes right side content

            // Right side: Timestamp and Unread Badge
            VStack(alignment: .trailing, spacing: 4) {
                 ServxTextView(
                     text: formattedTimestamp(conversation.lastMessageTimestampDate), // Use computed Date
                     color: .gray,
                     size: 12
                 )

                 if conversation.unreadCount > 0 {
                     // Unread count badge
                     Text("\(conversation.unreadCount)")
                         .font(.caption2)
                         .fontWeight(.bold)
                         .foregroundColor(.white)
                         .padding(.horizontal, 6)
                         .padding(.vertical, 2)
                         .background(Color.red) // Use theme color if desired
                         .clipShape(Capsule())
                 } else {
                     // Placeholder for consistent spacing
                     Text("").font(.caption2)
                 }
            }
        }
         .padding(.vertical, 8)
    }

     // Formats the date string for display
     private func formattedTimestamp(_ date: Date?) -> String {
         guard let date = date else { return "--" } // Handle nil date
         _ = Date()
         let calendar = Calendar.current

         if calendar.isDateInToday(date) {
             return date.formatted(date: .omitted, time: .shortened) // e.g., "10:30 AM"
         } else if calendar.isDateInYesterday(date) {
             return "Yesterday"
         } else {
             // Adjust format as needed
             return date.formatted() // e.g., "4/17/2025"
         }
     }
}
