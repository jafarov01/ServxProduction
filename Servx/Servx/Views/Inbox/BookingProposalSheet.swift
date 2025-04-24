//
//  BookingProposalSheet.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 20..
//


import SwiftUI

struct BookingProposalSheet: View {
    @StateObject private var viewModel: BookingProposalViewModel
    @Environment(\.dismiss) private var dismiss

    let onPropose: (BookingRequestPayload) -> Void

    init(requestId: Int64, onPropose: @escaping (BookingRequestPayload) -> Void) {
        _viewModel = StateObject(wrappedValue: BookingProposalViewModel(requestId: requestId))
        self.onPropose = onPropose
        print("BookingProposalSheet initialized for requestId: \(requestId)")
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Booking Details") {
                    Text(viewModel.serviceDetailsText)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    DatePicker("Proposed Date & Time", selection: $viewModel.proposedDate, displayedComponents: [.date, .hourAndMinute])
                         .datePickerStyle(.compact)
                         .environment(\.locale, Locale(identifier: "en_GB"))


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
                            onPropose(payload)
                            dismiss()
                        } else {
                             print("BookingProposalSheet: Payload creation failed (form invalid).")
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
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
