//
//  RegisterView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 11. 30..
//
import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(viewModel: @autoclosure @escaping () -> RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
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
            BackButton(action: navigationManager.goBack)
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
    
    private func inputFields() -> some View {
        VStack(spacing: 16) {
            // Personal Information
            ServxInputView(
                text: $viewModel.firstName,
                placeholder: "First Name",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )
            
            ServxInputView(
                text: $viewModel.lastName,
                placeholder: "Last Name",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )
            
            ServxInputView(
                text: $viewModel.email,
                placeholder: "Email",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300"),
                keyboardType: .emailAddress
            )
            
            ServxInputView(
                text: $viewModel.password,
                placeholder: "Password",
                isSecure: true,
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )
            
            ServxInputView(
                text: $viewModel.phoneNumber,
                placeholder: "Phone Number",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300"),
                keyboardType: .phonePad
            )
            
            // Address Information
            ServxInputView(
                text: $viewModel.addressLine,
                placeholder: "Address Line",
                frameColor: Color("primary100"),
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
                frameColor: Color("primary100"),
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
        guard viewModel.isValid else { return }
        
        viewModel.register { success in
            if success {
                navigationManager.navigate(to: .authentication)
            } else {
                // Handle registration error
            }
        }
    }
}
