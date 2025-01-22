//
//  ServiceSeekerRegistrationView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct ServiceSeekerRegistrationView: View {
    @ObservedObject var viewModel: RegisterViewModel
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 24) {
            // Navigation Header
            HStack {
                Button(action: {
                    navigationManager.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("primary500"))
                        .padding()
                }
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal)

            // Input Fields
            ScrollView {
                inputFields()
                    .padding(.horizontal, 24)
            }

            // Continue Button
            ServxButtonView(
                title: "Continue",
                width: 342,
                height: 56,
                frameColor: viewModel.isPersonalDetailsStageValid ? Color("primary500") : .gray,
                innerColor: viewModel.isPersonalDetailsStageValid ? Color("primary500") : .gray,
                textColor: .white,
                isDisabled: !viewModel.isPersonalDetailsStageValid,
                action: {
                    if viewModel.isPersonalDetailsStageValid {
                        viewModel.registerServiceSeeker { success in
                            if success {
                                navigationManager.navigate(to: .authentication)
                            } else {
                                // Handle error (e.g., show an alert)
                            }
                        }
                    }
                }
            )
            .opacity(viewModel.isPersonalDetailsStageValid ? 1 : 0.6)
            .padding(.top, 16)
        }
        .padding(.vertical, 24)
        .navigationBarBackButtonHidden(true)
    }

    private func inputFields() -> some View {
        VStack(spacing: 16) {
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
                text: $viewModel.phoneNumber,
                placeholder: "Phone Number",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300"),
                keyboardType: .phonePad
            )

            // Address Fields
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

            MultiSelectDropdownView(
                title: "Languages Spoken",
                options: viewModel.languageOptions,
                selectedOptions: $viewModel.selectedLanguages
            )
        }
    }
}
