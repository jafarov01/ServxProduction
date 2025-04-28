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
    let currentUserPhotoUrl: URL?
    let otherParticipantPhotoUrl: URL?
    var onBookingAccept: (() -> Void)? = nil
    var onBookingDecline: (() -> Void)? = nil
    var onShowBookingDetails: (() -> Void)? = nil

    private var senderPhotoUrl: URL? {
        return isCurrentUser ? currentUserPhotoUrl : otherParticipantPhotoUrl
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {

            if !isCurrentUser {
                ProfilePhotoView(imageUrl: senderPhotoUrl)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                Spacer(minLength: 0)
            } else {
                Spacer()
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4)
            {
                messageContent()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(bubbleBackground)
                    .foregroundColor(bubbleForegroundColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 2,
                        x: 1,
                        y: 1
                    )

                // Timestamp remains below the bubble, aligned correctly
                if let date = message.timestampDate {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 5)
                }
            }
            .frame(
                maxWidth: UIScreen.main.bounds.width * 0.70,
                alignment: isCurrentUser ? .trailing : .leading
            )

            if isCurrentUser {
                Spacer(minLength: 0)
                ProfilePhotoView(imageUrl: senderPhotoUrl)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal)  // Add horizontal padding to the whole row
        .id(message.id)  // Keep ID for ScrollViewReader
    }

    private var isBookingRequestMessage: Bool {
        return message.bookingPayload != nil
    }

    private var bubbleBackground: Color {
        if isBookingRequestMessage {
            return Color.orange.opacity(isCurrentUser ? 0.8 : 0.2)
        } else {
            return isCurrentUser
                ? ServxTheme.primaryColor : ServxTheme.greyScale100Color
        }
    }

    private var bubbleForegroundColor: Color {
        if isBookingRequestMessage {
            return isCurrentUser ? .white : Color(.label)
        } else {
            return isCurrentUser ? .white : Color(.label)
        }
    }

    @ViewBuilder
    private func messageContent() -> some View {
        if let payload = message.bookingPayload {
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8)
            {
                HStack(spacing: 5) {
                    Image(systemName: "calendar.badge.plus")
                    Text("Booking Request")
                    Spacer()
                }.font(.headline.weight(.semibold))

                Text("Proposed: \(formattedTimestamp(payload.agreedDate))")
                    .font(.subheadline)
                Text(
                    "Est. Price: \(formattedPriceRange(min: payload.priceMin, max: payload.priceMax))"
                )
                .font(.subheadline)
                if let notes = payload.notes, !notes.isEmpty {
                    Text("Notes: \(notes)")
                        .font(.subheadline)
                        .italic()
                }

                if !isCurrentUser {
                    Button {
                        print(
                            "MessageBubbleView: Show Details tapped for msg ID \(message.id)"
                        )
                        onShowBookingDetails?()
                    } label: {
                        Text("Show Details / Respond")
                            .font(.caption.weight(.semibold))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .foregroundColor(ServxTheme.primaryColor)
                            .overlay(
                                Capsule().stroke(
                                    ServxTheme.primaryColor,
                                    lineWidth: 1
                                )
                            )
                    }
                    .padding(.top, 5)
                } else {
                    Text("Proposal Sent")
                        .font(.caption)
                        .italic()
                        .foregroundColor(
                            isCurrentUser ? .white.opacity(0.8) : .gray
                        )
                        .padding(.top, 5)
                }
            }
            .foregroundColor(bubbleForegroundColor)

        } else {
            Text(message.content)
                .font(.body)
                .textSelection(.enabled)
        }
    }

    private func formattedTimestamp(_ date: Date?) -> String {
        guard let date = date else { return "Not specified" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private func formattedPriceRange(min: Double?, max: Double?) -> String {
        let minPrice = min ?? 0.0
        let maxPrice = max ?? minPrice
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let minStr =
            formatter.string(from: NSNumber(value: minPrice)) ?? "\(minPrice)"
        if minPrice == maxPrice {
            return minStr
        } else {
            let maxStr =
                formatter.string(from: NSNumber(value: maxPrice))
                ?? "\(maxPrice)"
            return "\(minStr) - \(maxStr)"
        }
    }
}
