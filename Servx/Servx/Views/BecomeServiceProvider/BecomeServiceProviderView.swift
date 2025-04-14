//
//  BecomeServiceProviderView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI
import Combine

/// SwiftUI View for the "Become a Service Provider" registration form.
struct BecomeServiceProviderView: View {
    @StateObject private var viewModel: BecomeServiceProviderViewModel
    @EnvironmentObject private var navigator: NavigationManager
    
    init(
        servicesService: ServicesServiceProtocol = ServicesService(),
        userService: UserServiceProtocol = UserService()
    ) {
        _viewModel = StateObject(
            wrappedValue: BecomeServiceProviderViewModel(
                servicesService: servicesService,
                userService: userService
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                educationSection
                categorySection
                subcategorySection
                serviceDetailsSection
                submitButton
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { viewModel.loadCategories() }
        .onChange(of: viewModel.didCompleteRegistration) { _, newValue in
            if newValue {
                navigator.goBack()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.submissionError != nil)) {
            Button("OK", role: .cancel) { viewModel.submissionError = nil }
        } message: {
            Text(viewModel.submissionError?.localizedDescription ?? "")
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        ServxTextView(
            text: "Become a Service Provider",
            color: ServxTheme.primaryColor,
            size: 24,
            weight: .bold,
            alignment: .center
        )
        .padding(.top, 40)
    }
    
    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ServxTextView(
                text: "Education Verification",
                color: ServxTheme.blackColor,
                size: 16,
                weight: .semibold
            )
            
            ServxInputView(
                text: $viewModel.education,
                placeholder: "Bachelor's Degree in Computer Science",
                frameColor: viewModel.education.count >= 10 ? ServxTheme.inputFieldBorderColor : .red,
                backgroundColor: ServxTheme.backgroundColor,
                textColor: ServxTheme.secondaryTextColor
            )
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ServxTextView(
                text: "Service Category",
                color: ServxTheme.blackColor,
                size: 16,
                weight: .semibold
            )
            
            ObjectOptionSelectionView(
                title: "Category",
                options: viewModel.categories,
                selectedOptionId: $viewModel.selectedCategoryId
            )
        }
    }
    
    private var subcategorySection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.selectedCategoryId != nil {
                VStack(alignment: .leading, spacing: 8) {
                    ServxTextView(
                        text: "Specializations",
                        color: ServxTheme.blackColor,
                        size: 16,
                        weight: .semibold
                    )
                    
                    MultiSelectDropdownView(
                        title: "Subcategories",
                        options: viewModel.subcategories,
                        selectedOptionIds: $viewModel.selectedSubcategoryIds
                    )
                }
            }
        }
    }
    
    private var serviceDetailsSection: some View {
        Group {
            if !viewModel.selectedSubcategoryIds.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    ServxTextView(
                        text: "Service Details",
                        color: ServxTheme.blackColor,
                        size: 16,
                        weight: .semibold
                    )
                    
                    ServxInputView(
                        text: $viewModel.workExperience,
                        placeholder: "Describe your professional experience...",
                        frameColor: (10...500).contains(viewModel.workExperience.count) ? ServxTheme.inputFieldBorderColor : .red,
                        backgroundColor: ServxTheme.backgroundColor,
                        textColor: ServxTheme.secondaryTextColor,
                    )
                    .frame(minHeight: 100)
                    .onChange(of: viewModel.workExperience) { _, newValue in
                        if newValue.count > 500 {
                            viewModel.workExperience = String(newValue.prefix(500))
                        }
                    }
                    
                    ServxInputView(
                        text: priceBinding,
                        placeholder: "Hourly rate in USD",
                        frameColor: (Double(viewModel.price) ?? 0) >= 0.01 ? ServxTheme.inputFieldBorderColor : .red,
                        backgroundColor: ServxTheme.backgroundColor,
                        textColor: ServxTheme.secondaryTextColor,
                        keyboardType: .decimalPad
                    )
                }
            }
        }
    }
    
    private var submitButton: some View {
        ServxButtonView(
            title: "Complete Registration",
            width: 342,
            height: 56,
            frameColor: viewModel.formValid ? ServxTheme.primaryColor : ServxTheme.buttonDisabledColor,
            innerColor: viewModel.formValid ? ServxTheme.primaryColor : ServxTheme.buttonDisabledColor,
            textColor: ServxTheme.backgroundColor,
            isDisabled: !viewModel.formValid,
            action: { Task { await viewModel.submitRegistration() } }
        )
        .opacity(viewModel.formValid ? 1 : 0.6)
    }
    
    private var priceBinding: Binding<String> {
        Binding(
            get: { viewModel.price },
            set: { newValue in
                viewModel.price = newValue
                    .filter { "0123456789.".contains($0) }
                    .replacingOccurrences(of: ",", with: ".")
            }
        )
    }
}
