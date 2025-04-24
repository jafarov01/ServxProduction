//
//  InboxView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()
    @EnvironmentObject private var navigator: NavigationManager

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.conversations.isEmpty {
                ProgressView("Loading Chats...")
            } else if !viewModel.conversations.isEmpty {
                List {
                    ForEach(viewModel.conversations) { conversation in
                         InboxRowView(conversation: conversation)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectConversation(requestId: conversation.id)
                            }
                            .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(.plain)
                .refreshable { await viewModel.loadConversations() }
                .onChange(of: viewModel.selectedRequestId) { _, newRequestId in
                    if let requestId = newRequestId {
                        print("InboxView: Navigating via manager to chat: \(requestId)")
                        navigator.inboxStack.append(AppRoute.Inbox.chat(requestId: requestId))
                        viewModel.selectedRequestId = nil
                    }
                }
            } else {
                Text("No conversations yet.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Inbox")
        .task {
            if viewModel.conversations.isEmpty {
                await viewModel.loadConversations()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _,_ in viewModel.errorMessage = nil }
        )) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
    }
}

// Represents a single row in the Inbox list
struct InboxRowView: View {
    let conversation: ChatConversationDTO

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                ServxTextView(
                    text: conversation.otherParticipantName,
                    size: 16, weight: conversation.unreadCount > 0 ? .semibold : .regular
                )

                ServxTextView(
                    text: conversation.lastMessage ?? "...",
                    color: .gray,
                    size: 14,
                    lineLimit: 1
                )
                .fontWeight(conversation.unreadCount > 0 ? .semibold : .regular)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                 ServxTextView(
                     text: formattedTimestamp(conversation.lastMessageTimestampDate),
                     color: .gray,
                     size: 12
                 )

                 if conversation.unreadCount > 0 {
                     Text("\(conversation.unreadCount)")
                         .font(.caption2)
                         .fontWeight(.bold)
                         .foregroundColor(.white)
                         .padding(.horizontal, 6)
                         .padding(.vertical, 2)
                         .background(Color.red)
                         .clipShape(Capsule())
                 } else {
                     Text("").font(.caption2)
                 }
            }
        }
         .padding(.vertical, 8)
    }

     private func formattedTimestamp(_ date: Date?) -> String {
         guard let date = date else { return "--" }
         _ = Date()
         let calendar = Calendar.current

         if calendar.isDateInToday(date) {
             return date.formatted(date: .omitted, time: .shortened)
         } else if calendar.isDateInYesterday(date) {
             return "Yesterday"
         } else {
             return date.formatted()
         }
     }
}
