//
//  ServiceRequestDetailView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI

struct ServiceRequestDetailView: View {
    @StateObject private var vm: ServiceRequestDetailViewModel
    @EnvironmentObject private var navigator: NavigationManager

    init(requestId: Int64) {
        _vm = StateObject(wrappedValue: ServiceRequestDetailViewModel(requestId: requestId))
        print("ServiceRequestDetailView initialized for requestId: \(requestId)")
    }
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let request = vm.request {
                        SectionView(title: "Service Request") {
                            InfoRow(label: "Description", value: request.description)
                            InfoRow(label: "Severity", value: request.severity.rawValue.capitalized)
                            InfoRow(label: "Status", value: request.status.rawValue.capitalized)
                            InfoRow(label: "Request Date", value: formattedDate(request.createdAt))
                        }

                        // Service Details Section
                        SectionView(title: "Service Details") {
                            InfoRow(label: "Category", value: request.service.categoryName)
                            InfoRow(label: "Subcategory", value: request.service.subcategoryName)
                            InfoRow(label: "Price", value: formattedPrice(request.service.price))
                            InfoRow(label: "Rating", value: formattedRating(request.service.rating))
                        }

                        // Client Details Section
                        SectionView(title: "Client Information") {
                            InfoRow(label: "Name", value: request.seeker.fullName)
                            InfoRow(label: "Phone", value: request.seeker.phoneNumber)
                            InfoRow(label: "Address", value: request.address.formattedAddress)
                        }

                        Group {
                            if vm.currentUserRole == .serviceProvider && request.status == .pending {
                                // PROVIDER sees Accept when Pending
                                ServxButtonView(
                                    title: "Accept Request",
                                    width: .infinity, height: 50,
                                    frameColor: .clear, innerColor: ServxTheme.primaryColor, textColor: .white,
                                    isDisabled: vm.isLoading,
                                    action: { Task { await vm.acceptRequest() } }
                                )
                            } else if vm.isChatActiveStatus(request.status) {
                                // BOTH Provider and Seeker see Chat button when Accepted/BookingConfirmed
                                let otherPersonName = vm.currentUserRole == .serviceProvider ? request.seeker.firstName : request.provider.firstName

                                ServxButtonView(
                                    title: "Chat with \(otherPersonName)",
                                    width: .infinity, height: 50,
                                    frameColor: ServxTheme.primaryColor, innerColor: .white,
                                    textColor: ServxTheme.primaryColor,
                                    icon: Image(systemName: "message.fill"),
                                    action: {
                                         print("ServiceRequestDetailView: 'Go to Chat' tapped.")
                                         navigator.navigateToChat(requestId: vm.requestId)
                                     }
                                )
                            } else {
                                EmptyView()
                            }
                        }
                        .padding(.top)

                    } else if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                         Text("Failed to load request details.")
                             .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Request #\(vm.requestId)")
            .task { await vm.loadRequestDetails() }
            .alert("Error", isPresented: $vm.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "Unknown error occurred")
            }
            .onChange(of: vm.submissionSuccess) { _, success in
                if success {
                     print("ServiceRequestDetailView: submissionSuccess changed to true, navigating to chat initially.")
                     navigator.navigateToChat(requestId: vm.requestId)
                }
            }
        }

        private func formattedDate(_ dateString: String) -> String {
             let formatter = ISO8601DateFormatter()
             formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
             guard let date = formatter.date(from: dateString) else {
                 formatter.formatOptions = [.withInternetDateTime] // Fallback
                 guard let date = formatter.date(from: dateString) else { return "Invalid Date" }
                 return formatDisplayDate(date)
             }
             return formatDisplayDate(date)
        }

         private func formatDisplayDate(_ date: Date) -> String {
             let displayFormatter = DateFormatter()
             displayFormatter.dateStyle = .medium
             displayFormatter.timeStyle = .short
             return displayFormatter.string(from: date)
         }

        private func formattedPrice(_ price: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        }

        private func formattedRating(_ rating: Double) -> String {
            String(format: "%.1f ★", rating)
        }
    }

// Reusable Section Component
struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var labelWidth: CGFloat = 100
    var valueAlignment: HorizontalAlignment = .leading
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: labelWidth, alignment: .leading)
            
            Text(value)
                .font(.body)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(valueAlignment == .leading ? .leading : .trailing)
        }
        .padding(.vertical, 4)
    }
}

