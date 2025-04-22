//
//  BookingProposalSheet.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 20..
//


import SwiftUI

struct BookingProposalSheet: View {
    // Create and own the ViewModel for the sheet's lifecycle
    @StateObject private var viewModel: BookingProposalViewModel
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) private var dismiss

    // Closure to call when proposal is successfully created
    let onPropose: (BookingRequestPayload) -> Void

    // Initializer receives the request ID to fetch details
    init(requestId: Int64, onPropose: @escaping (BookingRequestPayload) -> Void) {
        _viewModel = StateObject(wrappedValue: BookingProposalViewModel(requestId: requestId))
        self.onPropose = onPropose
        print("BookingProposalSheet initialized for requestId: \(requestId)")
    }

    var body: some View {
        NavigationView { // Embed in NavigationView for title and buttons
            Form {
                Section("Booking Details") {
                    Text(viewModel.serviceDetailsText) // Display fetched details
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    DatePicker("Proposed Date & Time", selection: $viewModel.proposedDate, displayedComponents: [.date, .hourAndMinute])
                        // Optional: Add range to prevent past dates
                         .datePickerStyle(.compact) // Or .graphical
                         .environment(\.locale, Locale(identifier: "en_GB")) // Example locale for formatting


                    HStack {
                         TextField("Min Price ($)", text: $viewModel.priceMinString)
                             .keyboardType(.decimalPad)
                         TextField("Max Price ($)", text: $viewModel.priceMaxString)
                             .keyboardType(.decimalPad)
                    }
                    
                    TextField("Duration (minutes)", text: $viewModel.durationString)
                                            .keyboardType(.numberPad)

                    TextEditor(text: $viewModel.notes)
                        .frame(height: 100)
                        .overlay(
                             RoundedRectangle(cornerRadius: 8)
                                 .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                        .overlay(alignment: .topLeading) {
                             if viewModel.notes.isEmpty {
                                 Text("Optional notes...")
                                     .foregroundColor(Color(UIColor.placeholderText))
                                     .padding(.horizontal, 8)
                                     .padding(.vertical, 12)
                                     .allowsHitTesting(false)
                             }
                        }
                }

                // Display validation error if any
                if let error = viewModel.errorMessage {
                    Section {
                         Text(error)
                             .foregroundColor(.red)
                             .font(.caption)
                    }
                }
            }
            .navigationTitle("Propose Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        if let payload = viewModel.createPayload() {
                            print("BookingProposalSheet: Sending payload.")
                            onPropose(payload) // Call completion handler
                            dismiss() // Dismiss the sheet
                        } else {
                             print("BookingProposalSheet: Payload creation failed (form invalid).")
                             // Error message should be displayed via viewModel.errorMessage
                        }
                    }
                    .disabled(!viewModel.isValid) // Disable if form invalid
                }
            }
             // Show loading indicator while initial details load
             .overlay {
                  if viewModel.isLoadingDetails {
                       ProgressView("Loading details...")
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(10)
                  }
             }
        }
    }
}
