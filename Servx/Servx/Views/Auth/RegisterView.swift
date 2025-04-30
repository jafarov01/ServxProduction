//
//  RegisterView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 11. 30..
//
import SwiftUI

struct RegisterView: View {
    @ObservedObject private var viewModel: RegisterViewModel
    @EnvironmentObject private var navigator: NavigationManager
    @EnvironmentObject private var session: UserSessionManager
    
    init(viewModel: RegisterViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            navigationHeader
            titleSection
            contentSection
            Spacer()
            ServiceAuthView(hasAccount: false)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - View Components
    private var navigationHeader: some View {
        HStack {
            BackButton(action: navigator.goBack)
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal)
    }
    
    private var titleSection: some View {
        ServxTextView(
            text: "Create Profile",
            color: Color("primary500"),
            size: 32,
            weight: .bold,
            alignment: .center
        )
        .padding(.top, 16)
    }
    
    private var contentSection: some View {
        ScrollView {
            VStack {
                VStack(spacing: 24) {
                    ScrollView {
                        inputFields()
                            .padding(.horizontal, 24)
                    }
                    continueButton
                }
                .padding(.vertical, 24)
            }
        }
        .padding(.horizontal)
    }
    
    private var continueButton: some View {
        ServxButtonView(
            title: "Continue",
            width: 342,
            height: 56,
            frameColor: viewModel.isValid ? Color("primary500") : .gray,
            innerColor: viewModel.isValid ? Color("primary500") : .gray,
            textColor: .white,
            isDisabled: !viewModel.isValid,
            action: handleRegistration
        )
        .opacity(viewModel.isValid ? 1 : 0.6)
        .padding(.top, 16)
    }
    
    // MARK: - Actions
    private func handleRegistration() {
        viewModel.printValidationStatus()
        guard viewModel.isValid else { return }
        
        viewModel.register { success in
            if success {
                navigator.navigate(to: AppRoute.Login.authentication)
            }
        }
    }
    
    private func inputFields() -> some View {
        VStack(spacing: 16) {
            // Personal Information
            ServxInputView(
                text: $viewModel.firstName,
                placeholder: "First Name",
                frameColor: viewModel.firstName.isEmpty ? .red : Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )
            
            ServxInputView(
                text: $viewModel.lastName,
                placeholder: "Last Name",
                frameColor: viewModel.lastName.isEmpty ? .red : Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )
            
            ServxInputView(
                text: $viewModel.email,
                placeholder: "Email",
                frameColor: viewModel.isValidEmail ? Color("primary100") : .red,
                backgroundColor: .white,
                textColor: Color("primary300"),
                keyboardType: .emailAddress
            )
            
            ServxInputView(
                text: $viewModel.password,
                placeholder: "Password",
                isSecure: true,
                frameColor: viewModel.isValidPassword ? Color("primary100") : .red,
                backgroundColor: .white,
                textColor: Color("primary300")
            )
            
            ServxInputView(
                text: $viewModel.phoneNumber,
                placeholder: "Phone Number",
                frameColor: viewModel.isValidPhoneNumber ? Color("primary100") : .red,
                backgroundColor: .white,
                textColor: Color("primary300"),
                keyboardType: .phonePad
            )
            .onChange(of: viewModel.phoneNumber) {
                handlePhoneNumberFormatting()
            }
            
            // Address Information
            ServxInputView(
                text: $viewModel.addressLine,
                placeholder: "Address Line",
                frameColor: viewModel.addressLine.isEmpty ? .red : Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )
            
            OptionSelectionView(
                title: "Country",
                options: viewModel.countryOptions,
                selectedOption: $viewModel.selectedCountry
            )
            
            OptionSelectionView(
                title: "City",
                options: viewModel.cityOptions(for: viewModel.selectedCountry),
                selectedOption: $viewModel.selectedCity
            )
            
            ServxInputView(
                text: $viewModel.zipCode,
                placeholder: "Zip Code",
                frameColor: viewModel.zipCode.isEmpty ? .red : Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300"),
                keyboardType: .numbersAndPunctuation
            )
            
            // Language Selection
            MultiSelectStringDropdownView(
                title: "Languages Spoken",
                options: viewModel.languageOptions,
                selectedOptions: $viewModel.selectedLanguages
            )
        }
    }
    
    private func handlePhoneNumberFormatting() {
        let filtered = viewModel.phoneNumber
            .filter { $0.isNumber || $0 == "+" }
            .prefix(16)
        
        let formatted = filtered.isEmpty ? "" :
            filtered.first == "+" ? String(filtered) : "+" + filtered
        
        if viewModel.phoneNumber != formatted {
            viewModel.phoneNumber = formatted
        }
    }
}
