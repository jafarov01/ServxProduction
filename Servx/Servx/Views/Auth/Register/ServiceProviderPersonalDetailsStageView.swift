//
//  ServiceProviderRegistrationProfileDetailsStageView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct ServiceProviderPersonalDetailsStageView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @ObservedObject var viewModel: RegisterViewModel
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 24) {
                    // Input Fields
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
                        text: $viewModel.phoneNumber,
                        placeholder: "Phone Number",
                        frameColor: Color("primary100"),
                        backgroundColor: .white,
                        textColor: Color("primary300"),
                        keyboardType: .phonePad
                    )

                    OptionSelectionView(
                        title: "Country",
                        options: viewModel.countryOptions,
                        selectedOption: $viewModel.selectedCountry
                    )

                    // Dynamically update city options based on selected country
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

                    OptionSelectionView(
                        title: "Education",
                        options: viewModel.educationOptions,
                        selectedOption: $viewModel.education
                    )

                    // Languages Spoken Field
                    MultiSelectDropdownView(
                        title: "Languages Spoken",
                        options: viewModel.languageOptions,
                        selectedOptions: $viewModel.selectedLanguages
                    )
                }

                // Next Button
                ServxButtonView(
                    title: "Next",
                    width: 200,
                    height: 50,
                    frameColor: viewModel.isPersonalDetailsStageValid ? Color("primary500") : .gray,
                    innerColor: viewModel.isPersonalDetailsStageValid ? Color("primary500") : .gray,
                    textColor: .white,
                    cornerRadius: 12,
                    isDisabled: !viewModel.isPersonalDetailsStageValid,
                    action: {
                        if viewModel.isPersonalDetailsStageValid {
                            onNext()
                        }
                    }
                )
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
    }
}
