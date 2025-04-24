//
//  BookingConfirmationSheet.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 20..
//


import SwiftUI

struct BookingConfirmationSheet: View {
    let payload: BookingRequestPayload
    let senderName: String
    let requestStatus: ServiceRequest.RequestStatus?
    let onAccept: () -> Void
    let onReject: () -> Void

    @Environment(\.dismiss) private var dismiss

    init(
        payload: BookingRequestPayload,
        senderName: String,
        requestStatus: ServiceRequest.RequestStatus?,
        onAccept: @escaping () -> Void,
        onReject: @escaping () -> Void
    ) {
        self.payload = payload
        self.senderName = senderName
        self.requestStatus = requestStatus
        self.onAccept = onAccept
        self.onReject = onReject
        print("BookingConfirmationSheet initialized with status: \(String(describing: requestStatus))")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionView(title: "Proposal From") {
                         InfoRow(label: "Provider", value: senderName)
                    }

                    SectionView(title: "Service Details") {
                        Text(payload.serviceRequestDetailsText)
                            .font(.subheadline)
                    }

                    SectionView(title: "Proposed Booking") {
                        InfoRow(label: "Date & Time", value: formattedTimestamp(payload.agreedDate))
                        InfoRow(label: "Est. Price", value: formattedPriceRange(min: payload.priceMin, max: payload.priceMax))
                        if let notes = payload.notes, !notes.isEmpty {
                            InfoRow(label: "Notes", value: notes)
                        }
                    }

                    actionSection()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Booking Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func actionSection() -> some View {
         Group {
             if requestStatus == .accepted {
                 HStack(spacing: 15) {
                      ServxButtonView(
                          title: "Reject", width: 120, height: 44, frameColor: .red, innerColor: .white, textColor: .red, font: .body.weight(.medium)
                      ) { onReject(); dismiss() }

                      ServxButtonView(
                          title: "Accept", width: 120, height: 44, frameColor: ServxTheme.primaryColor, innerColor: ServxTheme.primaryColor, textColor: .white, font: .body.weight(.medium)
                      ) { onAccept(); dismiss() }
                 }
                 .frame(maxWidth: .infinity)
                 .padding(.top)

             } else if requestStatus == .bookingConfirmed {
                  Text("Booking Confirmed")
                      .font(.headline).foregroundColor(.green)
                      .frame(maxWidth: .infinity, alignment: .center).padding()
             } else if requestStatus == .declined {
                  Text("Booking Was Declined")
                      .font(.headline).foregroundColor(.red)
                      .frame(maxWidth: .infinity, alignment: .center).padding()
             } else {
                   Text("Status: \(requestStatus?.rawValue ?? "Unavailable")")
                      .font(.headline).foregroundColor(.gray)
                      .frame(maxWidth: .infinity, alignment: .center).padding()
             }
        }
    }

    private func formattedTimestamp(_ date: Date?) -> String {
        guard let date = date else { return "Not specified" }
        return date.formatted(date: .long, time: .shortened)
    }

    private func formattedPriceRange(min: Double?, max: Double?) -> String {
        let minPrice = min ?? 0.0
        let maxPrice = max ?? minPrice
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let minStr = formatter.string(from: NSNumber(value: minPrice)) ?? "\(minPrice)"
        if minPrice == maxPrice {
            return minStr
        } else {
            let maxStr = formatter.string(from: NSNumber(value: maxPrice)) ?? "\(maxPrice)"
            return "\(minStr) - \(maxStr)"
        }
    }
}
