//
//  ServiceProviderRegistrationInitialStageView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import SwiftUI

struct ServiceProviderRegistrationInitialStageView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @ObservedObject var viewModel: RegisterViewModel
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Navigation Header
            HStack {
                Button(action: {
                    navigationManager.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .padding()
                }
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal)

            // Input Fields
            VStack(spacing: 16) {
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
            }

            // Next Button
            ServxButtonView(
                title: "Next",
                width: 200,
                height: 50,
                frameColor: viewModel.isInitialStageValid ? ServxTheme.linkTextColor : ServxTheme.buttonDisabledColor,
                innerColor: viewModel.isInitialStageValid ? ServxTheme.linkTextColor : ServxTheme.buttonDisabledColor,
                textColor: ServxTheme.backgroundColor,
                isDisabled: !viewModel.isInitialStageValid,
                action: {
                    if viewModel.isInitialStageValid {
                        onNext()
                    }
                }
            )
            .opacity(viewModel.isInitialStageValid ? 1 : 0.6) // Disabled state opacity
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
    }
}
