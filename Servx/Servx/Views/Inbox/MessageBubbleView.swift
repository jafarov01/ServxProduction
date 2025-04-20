//
//  MessageBubbleView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 19..
//


import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessageDTO
    let isCurrentUser: Bool
    // Add closures for booking actions (called by buttons)
    var onBookingAccept: (() -> Void)? = nil
    var onBookingDecline: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom, spacing: 5) { // Align timestamp better
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                messageContent()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(bubbleBackground)
                    .foregroundColor(bubbleForegroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 1, y: 1)

                // Timestamp (using parsed date)
                if let date = message.timestampDate {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        // Add padding to align with bubble edge slightly better
                        .padding(.horizontal, isCurrentUser ? 0 : 5)
                        .padding(.trailing, isCurrentUser ? 5 : 0)
                }
            }
             // Constrain bubble width
             .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isCurrentUser ? .trailing : .leading)

            if !isCurrentUser { Spacer() }
        }
        .padding(.vertical, 3)
        .id(message.id) // Ensure bubble redraws if message content changes (e.g., booking status)
    }

    // Determine bubble background color
    private var bubbleBackground: Color {
        if isBookingRequest(message.content) {
             return Color.orange.opacity(isCurrentUser ? 0.8 : 0.2)
        } else {
             return isCurrentUser ? ServxTheme.primaryColor : ServxTheme.greyScale100Color
        }
    }

     // Determine text color
    private var bubbleForegroundColor: Color {
        if isBookingRequest(message.content) {
            return isCurrentUser ? .white : Color(.label) // Or maybe always dark text?
        } else {
             return isCurrentUser ? .white : Color(.label)
        }
    }

    // Check if message content indicates a booking request
    private func isBookingRequest(_ content: String) -> Bool {
         // Use a reliable marker maybe stored in message payload later?
         // For now, check for prefix. Make this robust.
         return content.uppercased().starts(with: "[BOOKING_REQUEST]")
    }

    // Build message content view
    @ViewBuilder
    private func messageContent() -> some View {
        if isBookingRequest(message.content) {
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8) {
                HStack(spacing: 5) {
                     Image(systemName: "calendar.badge.plus")
                     Text("Booking Request")
                     Spacer() // Push content left
                 }.font(.headline.weight(.semibold))

                // Extract details if possible, otherwise use placeholder
                 // let details = parseBookingDetails(message.content)
                 Text("Please review the proposed booking details and respond.") // Placeholder detail
                      .font(.subheadline)

                 // Show Accept/Decline only for the recipient (Seeker)
                 if !isCurrentUser {
                     HStack(spacing: 10) {
                         ServxButtonView(
                             title: "Decline", width: 100, height: 35,
                             frameColor: .red, innerColor: .white, textColor: .red,
                             font: .caption.weight(.semibold)
                         ) {
                             print("Booking Decline Tapped")
                             onBookingDecline?() // Call closure passed from ChatView
                         }
                         ServxButtonView(
                             title: "Accept", width: 100, height: 35,
                             frameColor: .green, innerColor: .white, textColor: .green,
                             font: .caption.weight(.semibold)
                         ) {
                              print("Booking Accept Tapped")
                             onBookingAccept?() // Call closure passed from ChatView
                         }
                     }
                     .padding(.top, 5)
                 }
                 // TODO: Add visual indicator if booking was accepted/declined later
            }
        } else {
            // Standard text message
            Text(message.content)
                .font(.body)
                 // Allow selecting/copying text
                 .textSelection(.enabled)
        }
    }
}