//
//  ChatView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 19..
//


import SwiftUI
import Combine
import UIKit

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @EnvironmentObject private var navigator: NavigationManager
    @State private var keyboardHeight: CGFloat = 0
    @Namespace private var bottomID
    @State private var showingBookingSheet = false

    init(requestId: Int64) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            requestId: requestId,
            authenticatedUser: AuthenticatedUser.shared,
            webSocketManager: WebSocketManager.shared
        ))
        print("ChatView initialized for requestId: \(requestId)")
    }
    
    private var bottomSafeAreaInset: CGFloat {
        (UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.safeAreaInsets.bottom) ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
             HStack {
                 Button { navigator.goBack() } label: {
                     Image(systemName: "chevron.left")
                          .font(.title3.weight(.medium))
                          .foregroundColor(ServxTheme.primaryColor)
                 }
                 Spacer()
                 Text(viewModel.otherParticipantName)
                    .font(.headline)
                 Spacer()
                  Button {} label: { Image(systemName: "chevron.left").opacity(0) } .disabled(true)

             }
             .padding(.horizontal)
             .padding(.bottom, 6)
             .padding(.top, 5)

            messageList()
            Divider()
            inputArea()
        }
        .navigationTitle(viewModel.otherParticipantName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadInitialData()
        }
        .alert(item: $viewModel.errorWrapper) { wrapper in
            Alert(title: Text("Error"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingBookingSheet) {
            BookingProposalSheet(requestId: viewModel.requestId) { payload in
                viewModel.sendBookingRequest(payload: payload)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $viewModel.bookingMessageToShowDetails) { messageToShow in
             if let payload = messageToShow.bookingPayload {
                 BookingConfirmationSheet(
                     payload: payload,
                     senderName: messageToShow.senderName ?? "Provider",
                     requestStatus: viewModel.currentRequestStatus, // Pass status here
                     onAccept: { viewModel.handleBookingAccept(messageId: messageToShow.id) },
                     onReject: { viewModel.handleBookingDecline(messageId: messageToShow.id) }
                 )
                 .presentationDetents([.medium])
             } else {
                  Text("Error: Booking details not found.")
             }
        }
        .onReceive(Publishers.keyboardHeight) { height in
             withAnimation(.easeInOut(duration: 0.25)) {
                  self.keyboardHeight = height > 0 ? height - bottomSafeAreaInset : 0
             }
        }
    }

    @ViewBuilder
    private func messageList() -> some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(showsIndicators: false) {
                if viewModel.isLoadingMessages && viewModel.messages.isEmpty {
                     ProgressView().padding(.vertical)
                }

                LazyVStack(spacing: 5) {
                     if viewModel.canLoadMoreMessages && !viewModel.messages.isEmpty {
                          if viewModel.isLoadingMessages {
                              ProgressView().padding(.vertical)
                          } else {
                              Button("Load More Messages") {
                                   Task { await viewModel.loadMoreMessages() }
                              }
                              .padding(.vertical)
                          }
                     }

                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isCurrentUser: viewModel.isCurrentUser(senderId: message.senderId),
                            onBookingAccept: { viewModel.handleBookingAccept(messageId: message.id) },
                            onBookingDecline: { viewModel.handleBookingDecline(messageId: message.id) },
                            onShowBookingDetails: { viewModel.showBookingDetails(for: message) }
                        )
                        .id(message.id)
                         .onAppear {
                             if message.id == viewModel.messages.first?.id && viewModel.canLoadMoreMessages && !viewModel.isLoadingMessages {
                                 Task { await viewModel.loadMoreMessages() }
                             }
                         }
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                 .padding(.horizontal)
                 .padding(.top, 5)
            }
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
        if viewModel.canSendMessage {
             HStack(alignment: .bottom, spacing: 8) {
                 if viewModel.currentUserRole == .serviceProvider {
                     ServxButtonView(
                         title: "📅", width: 40, height: 40,
                         frameColor: ServxTheme.primaryColor,
                         innerColor: ServxTheme.primaryColor.opacity(0.1),
                         textColor: ServxTheme.primaryColor,
                         cornerRadius: 20
                     ) { showingBookingSheet = true }
                     .disabled(viewModel.isSending)
                 }

                 TextEditor(text: $viewModel.messageText)
                      .frame(minHeight: 35, maxHeight: 100)
                      .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                      .background(ServxTheme.greyScale100Color)
                      .cornerRadius(17.5)
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
            .padding(.bottom, keyboardHeight)
        } else {
            Text("Chat disabled")
                .font(.caption).foregroundColor(.secondary).padding(.vertical, 10)
                .frame(maxWidth: .infinity).background(.thinMaterial)
        }
    }

    private func scrollToLastMessage(proxy: ScrollViewProxy, animated: Bool) {
        print("ChatView: Scrolling to bottom anchor")
        let anchorId = "bottom"
        if animated {
            withAnimation(.spring()) { proxy.scrollTo(anchorId, anchor: .bottom) }
        } else {
            proxy.scrollTo(anchorId, anchor: .bottom)
        }
    }

    private func scrollToMessage(proxy: ScrollViewProxy, id: Int64, anchor: UnitPoint?, animated: Bool) {
        print("ChatView: Scrolling to message ID \(id)")
        if animated {
            withAnimation { proxy.scrollTo(id, anchor: anchor ?? .top) }
        } else {
            proxy.scrollTo(id, anchor: anchor ?? .top)
        }
    }
}

extension Foundation.Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                notification.keyboardHeight
            }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                CGFloat(0)
            }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
