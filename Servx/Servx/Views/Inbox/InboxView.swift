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
        HStack(spacing: 12) {

            ProfilePhotoView(imageUrl: conversation.otherParticipantPhotoUrl)
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.otherParticipantName)
                    .font(.system(size: 16, weight: conversation.unreadCount > 0 ? .semibold : .medium))
                    .foregroundColor(Color("primary500"))
                    .lineLimit(1)


                Text(conversation.lastMessage ?? "...")
                    .font(.system(size: 14))
                    .foregroundColor(conversation.unreadCount > 0 ? Color(.label).opacity(0.9) : .secondary)
                    .lineLimit(1)
                    .fontWeight(conversation.unreadCount > 0 ? .medium : .regular)

            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text(formattedTimestamp(conversation.lastMessageTimestampDate))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)


                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .clipShape(Capsule())
                } else {
                     Spacer().frame(height: 16)
                }
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }

    private func formattedTimestamp(_ date: Date?) -> String {
        guard let date = date else { return "--" }
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
             return date.formatted(.dateTime.weekday(.abbreviated))
         } else {
            return date.formatted(date: .numeric, time: .omitted)
        }
    }
}
