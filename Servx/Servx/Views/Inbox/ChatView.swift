//
//  ChatView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 19..
//


import SwiftUI
import Combine
import UIKit
import Foundation

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @EnvironmentObject private var navigator: NavigationManager
    @State private var keyboardHeight: CGFloat = 0
    // Use namespace for smooth scrolling transitions
    @Namespace private var bottomID

    init(requestId: Int64) {
        // Create the ViewModel here inside the View's init.
        // It now only needs the requestId, as it fetches participant info itself.
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            requestId: requestId,
            authenticatedUser: AuthenticatedUser.shared,
            webSocketManager: WebSocketManager.shared
        ))
        print("ChatView initialized for requestId: \(requestId)")
    }
    var body: some View {

        
        VStack(spacing: 0) {
            HStack {
                Button(action: navigator.goBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding()
            messageList()
            Divider()
            inputArea()
        }
        .navigationTitle(viewModel.otherParticipantName)
        .navigationBarBackButtonHidden()
        .task { await viewModel.loadInitialData() } // Load history on appear
        .onAppear {
             print("ChatView appeared")
             Task { await viewModel.markConversationAsRead() }
             // Subscribe to messages WHEN the view appears
            viewModel.setupWebSocketSubscription()
        }
        .alert(item: $viewModel.errorWrapper) { wrapper in // Use item alert
            Alert(
                title: Text("Error"),
                message: Text(wrapper.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onReceive(Publishers.keyboardHeight) { height in
            // Animate padding adjustments based on keyboard height
             withAnimation(.easeInOut(duration: 0.25)) {
                 // Adjust padding based on safe area insets if needed
                 self.keyboardHeight = height > 0 ? height - 34 : 0 // Approximate safe area bottom inset
             }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func messageList() -> some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(showsIndicators: false) { // Hide scroll indicator
                 // Loading indicator at the top for pagination
                 if viewModel.isLoadingMessages && viewModel.messages.count > 0 {
                      ProgressView().padding(.vertical)
                 }

                LazyVStack(spacing: 5) {
                     // GeometryReader to detect reaching the top
                     GeometryReader { geometry in
                         Color.clear
                             .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                     }
                     .frame(height: 1) // Minimal height
                     // Flip content vertically

                     // Iterate through messages
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isCurrentUser: viewModel.isCurrentUser(senderId: message.senderId),
                            // Pass actions for booking responses
                            onBookingAccept: {
                                viewModel.handleBookingAccept(messageId: message.id)
                            },
                            onBookingDecline: {
                                 viewModel.handleBookingDecline(messageId: message.id)
                            }
                        )
                        .id(message.id)
                    }
                    // Add an invisible view at the bottom for scrolling
                    Color.clear.frame(height: 1).id("bottom")
                }
                 .padding(.horizontal)
                 .padding(.top, 5)
            }
             .coordinateSpace(name: "scroll") // Name the coordinate space
             .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                 // Trigger load more when top is reached (value > threshold)
                  // Needs adjustment based on content size/padding
                  if value > -50 && viewModel.canLoadMoreMessages && !viewModel.isLoadingMessages {
                       Task {
                           print("ChatView: Reached top (offset: \(value)), loading more...")
                           await viewModel.loadMoreMessages()
                       }
                  }
             }
             // Handle scroll requests from ViewModel
             .onReceive(viewModel.scrollToBottomPublisher) { animated in
                 scrollToLastMessage(proxy: scrollViewProxy, animated: animated)
             }
             .onReceive(viewModel.scrollToMessagePublisher) { data in
                 scrollToMessage(proxy: scrollViewProxy, id: data.id, anchor: data.anchor, animated: true)
             }
        }
    }

    @ViewBuilder
    private func inputArea() -> some View {
        // Only show if chat is active
        if viewModel.canSendMessage {
             HStack(alignment: .bottom, spacing: 8) {
                 // Booking Request Button (Provider only)
                 if viewModel.currentUserRole == .serviceProvider {
                     ServxButtonView(
                         title: "📅", width: 40, height: 40,
                         frameColor: ServxTheme.primaryColor,
                         innerColor: ServxTheme.primaryColor.opacity(0.1),
                         textColor: ServxTheme.primaryColor,
                         cornerRadius: 20
                     ) { viewModel.sendBookingRequest() }
                         .disabled(viewModel.isSending)
                 }

                 // Use TextEditor for potentially multiline input
                 TextEditor(text: $viewModel.messageText)
                      .frame(minHeight: 30, maxHeight: 100) // Limit height
                      .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                      .background(ServxTheme.greyScale100Color)
                      .cornerRadius(20)
                      .overlay(
                          HStack {
                              if viewModel.messageText.isEmpty {
                                   Text("Type message...")
                                       .foregroundColor(Color(UIColor.placeholderText))
                                       .padding(.leading, 12 + 5)
                                       .allowsHitTesting(false)
                                   Spacer()
                              }
                          }
                      )
                      .fixedSize(horizontal: false, vertical: true)
                      .disabled(viewModel.isSending)

                 // Send Button
                 ServxButtonView(
                     title: "", width: 40, height: 40,
                     frameColor: .clear,
                     innerColor: viewModel.messageText.isEmpty ? ServxTheme.buttonDisabledColor : ServxTheme.primaryColor,
                     textColor: .white,
                     cornerRadius: 20, icon: Image(systemName: "paperplane.fill"),
                     isDisabled: viewModel.messageText.isEmpty || viewModel.isSending
                 ) { viewModel.sendMessage() }

            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.thinMaterial)
            // Apply bottom padding only when keyboard is visible
             .padding(.bottom, keyboardHeight)
        } else {
            // Disabled chat indicator
            Text("Chat disabled") // Simpler message
                .font(.caption).foregroundColor(.secondary).padding(.vertical, 10)
                .frame(maxWidth: .infinity).background(.thinMaterial)
        }
    }

     // MARK: - Scroll Helpers

     private func scrollToLastMessage(proxy: ScrollViewProxy, animated: Bool) {
         // Scroll to the invisible view at the bottom
         print("ChatView: Scrolling to bottom anchor")
         if animated {
             withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
         } else {
             proxy.scrollTo("bottom", anchor: .bottom)
         }
     }

     private func scrollToMessage(proxy: ScrollViewProxy, id: Int64, anchor: UnitPoint?, animated: Bool) {
         print("ChatView: Scrolling to message ID \(id)")
         if animated {
             withAnimation { proxy.scrollTo(id, anchor: anchor ?? .center) }
         } else {
             proxy.scrollTo(id, anchor: anchor ?? .center)
         }
     }
}

// --- Preference Key for Scroll Offset ---
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


// Extension to publish keyboard height changes
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // Use the correct publisher for Notification.Name
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in // $0 is the Notification object
                // Use the keyboardHeight computed property below
                notification.keyboardHeight
            }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in // We don't need the notification object here
                CGFloat(0) // Return 0 on hide
            }

        // Merge the two streams
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher() // Type erase
    }
}

// Helper extension on Notification to easily get height
extension Foundation.Notification {
    var keyboardHeight: CGFloat {
        // Access the 'userInfo' property of the Foundation.Notification instance
        // Using 'self.' is optional but clear: self.userInfo
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
