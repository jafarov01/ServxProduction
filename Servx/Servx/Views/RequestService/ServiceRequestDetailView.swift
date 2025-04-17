//
//  ServiceRequestDetailView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 16..
//

import SwiftUI

struct ServiceRequestDetailView: View {
    @StateObject var vm: ServiceRequestDetailViewModel
    @EnvironmentObject var navigator: NavigationManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let request = vm.request {
                    // Request Details Section
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
                    
                    // Action Button
                    if request.status == .pending {
                        ServxButtonView(
                            title: "Accept Request",
                            width: .infinity,
                            height: 50,
                            frameColor: .clear,
                            innerColor: ServxTheme.primaryColor,
                            textColor: .white,
                            action: { Task { await vm.acceptRequest() } }
                        )
                        .padding(.top)
                    }
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                navigator.navigateToChat(requestId: vm.requestId)
            }
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        guard let date = dateString.toDate() else { return "Invalid date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
