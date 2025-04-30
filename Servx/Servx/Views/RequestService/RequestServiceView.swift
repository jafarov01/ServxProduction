//
//  RequestServiceView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 14..
//

import SwiftUI

struct RequestServiceView: View {
    @StateObject private var viewModel: RequestServiceViewModel
    @EnvironmentObject private var navigator: NavigationManager

    // Initializer takes the ServiceProfile data needed by the ViewModel
    init(serviceProfile: ServiceProfile) {
        _viewModel = StateObject(wrappedValue: RequestServiceViewModel(service: serviceProfile))
        print("RequestServiceView initialized for service: \(serviceProfile.providerName)")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Service Provider Header
            ServiceProviderHeader(service: viewModel.service)
            
            // Request Details
            descriptionField
            severityPicker
            addressSection
            
            // Submit Button
            submitButton
        }
        .padding()
        .navigationTitle("New Request")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    navigator.goBack()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onChange(of: viewModel.submissionSuccess) { _, success in
            if success {
                navigator.goBack()
            }
        }
    }
    
    private var descriptionField: some View {
        ServxInputView(
            text: $viewModel.description,
            placeholder: "Describe your issue in detail...",
            frameColor: ServxTheme.greyScale400Color,
            backgroundColor: ServxTheme.greyScale100Color,
            textColor: ServxTheme.blackColor
        )
        .frame(minHeight: 120)
    }
    
    private var severityPicker: some View {
        OptionSelectionView(
            title: "Severity Level",
            options: ServiceRequest.SeverityLevel.allCases.map { $0.rawValue.capitalized },
            selectedOption: $viewModel.selectedSeverity
        )
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ServxTextView(text: "Service Address", size: 16, weight: .semibold)
            ServxTextView(text: viewModel.userAddress.formattedAddress, color: .gray)
        }
    }
    
    private var submitButton: some View {
        ServxButtonView(
            title: "Submit Request",
            width: .infinity,
            height: 44,
            frameColor: ServxTheme.primaryColor,
            innerColor: ServxTheme.primaryColor,
            textColor: .white,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.submitRequest() }
        }
        .padding(.vertical)
    }
}

struct ServiceProviderHeader: View {
    let service: ServiceProfile
    
    var body: some View {
        HStack(spacing: 16) {
            ProfilePhotoView(imageUrl: service.profilePhotoUrl)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(service.providerName)
                    .font(.headline)
                
                HStack {
                    StaticStarRatingView(rating: service.rating)
                    Text("(\(service.reviewCount))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(service.serviceTitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}
