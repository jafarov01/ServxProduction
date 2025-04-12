//
//  BecomeServiceProviderView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct BecomeServiceProviderView: View {
    @StateObject private var viewModel: BecomeServiceProviderViewModel
    @EnvironmentObject private var userSession: UserSessionManager
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(servicesService: ServicesServiceProtocol = ServicesService()) {
        _viewModel = StateObject(wrappedValue: BecomeServiceProviderViewModel(servicesService: servicesService))
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
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
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
                frameColor: viewModel.educationValid ? ServxTheme.inputFieldBorderColor : .red,
                backgroundColor: ServxTheme.backgroundColor,
                textColor: ServxTheme.secondaryTextColor,
                keyboardType: .default
            )
            
            if !viewModel.educationValid {
                validationMessage(viewModel.educationError)
            }
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
            
            if !viewModel.categoryValid {
                validationMessage("Please select a category")
            }
        }
    }
    
    private var subcategorySection: some View {
        Group {
            if viewModel.isLoadingSubcategories {
                ProgressView()
                    .frame(maxWidth: .infinity)
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
                    
                    if !viewModel.subcategoriesValid {
                        validationMessage("Select at least one specialization")
                    }
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
                        frameColor: viewModel.workExperienceValid ? ServxTheme.inputFieldBorderColor : .red,
                        backgroundColor: ServxTheme.backgroundColor,
                        textColor: ServxTheme.secondaryTextColor,
                        keyboardType: .default
                    )
                    .frame(minHeight: 100)
                    
                    if !viewModel.workExperienceValid {
                        validationMessage(viewModel.workExperienceError)
                    }
                    
                    ServxInputView(
                        text: priceBinding,
                        placeholder: "Hourly rate in USD",
                        frameColor: viewModel.priceValid ? ServxTheme.inputFieldBorderColor : .red,
                        backgroundColor: ServxTheme.backgroundColor,
                        textColor: ServxTheme.secondaryTextColor,
                        keyboardType: .decimalPad
                    )
                    .onChange(of: viewModel.price) {
                        viewModel.validatePriceFormat()
                    }
                    
                    if !viewModel.priceValid {
                        validationMessage(viewModel.priceError)
                    }
                }
            }
        }
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
    
    private var submitButton: some View {
        ServxButtonView(
            title: "Complete Registration",
            width: 342,
            height: 56,
            frameColor: viewModel.formValid ? ServxTheme.primaryColor : ServxTheme.buttonDisabledColor,
            innerColor: viewModel.formValid ? ServxTheme.primaryColor : ServxTheme.buttonDisabledColor,
            textColor: ServxTheme.backgroundColor,
            isDisabled: !viewModel.formValid || viewModel.isSubmitting,
            action: { Task { await viewModel.submitRegistration() } }
        )
        .opacity(viewModel.formValid ? 1 : 0.6)
    }
    
    // MARK: - Helper Methods
    
    private func validationMessage(_ text: String) -> some View {
        ServxTextView(
            text: text,
            color: .red,
            size: 14,
            weight: .regular,
            paddingValues: EdgeInsets(top: 4, leading: 8, bottom: 0, trailing: 8)
        )
    }
}
