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
        
        HStack {
            Button(action: {
                navigationManager.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .padding()
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .frame(height: 44)
        
        VStack(spacing: 24) {
            // Input Fields
            inputFields()

            // Remember Me Toggle
            Toggle(isOn: $viewModel.isRememberMe) {
                ServxTextView(
                    text: "Remember me",
                    color: .black,
                    size: 16,
                    weight: .regular
                )
            }
            .toggleStyle(.switch)
            .padding(.horizontal, 25)

            // Continue Button
//            ServxButtonView(
//                title: "Continue",
//                width: 342,
//                height: 56,
//                frameColor: viewModel.isFormValid ? Color("primary200") : .gray,
//                innerColor: viewModel.isFormValid ? Color("primary200") : .gray,
//                textColor: .white,
//                isDisabled: !viewModel.isFormValid,
//                action: {
//                    if viewModel.isFormValid {
//                        viewModel.createProfile()
//                        navigationManager.navigate(to: .home)
//                    }
//                }
//            )
        }
//        .onAppear(){
//            viewModel.testValidation()
//        }
        .padding(24)
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

            ServxInputView(
                text: $viewModel.address,
                placeholder: "Current Address",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )

            ServxInputView(
                text: $viewModel.country,
                placeholder: "Country",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )

            ServxInputView(
                text: $viewModel.city,
                placeholder: "City",
                frameColor: Color("primary100"),
                backgroundColor: .white,
                textColor: Color("primary300")
            )
        }
    }
}
