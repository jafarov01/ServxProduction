//
//  ForgotPasswordView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import SwiftUI
import Foundation

struct ForgotPasswordView: View {
    @StateObject private var viewModel: ForgotPasswordViewModel

    init(authService: AuthServiceProtocol = AuthService()) {
         _viewModel = StateObject(wrappedValue: ForgotPasswordViewModel(authService: authService))
    }

    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {

        VStack(spacing: 15) {

            HStack {
                Button {
                    navigationManager.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("primary500"))
                        .font(.title2)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

             ServxTextView(
                 text: "Forgot Password",
                 color: ServxTheme.primaryColor,
                 size: 24,
                 weight: .bold,
                 alignment: .center
             )
             .padding(.top, 20)


             ServxTextView(
                 text: "Enter your email address to receive a password reset link.",
                 color: ServxTheme.blackColor,
                 size: 16,
                 weight: .regular,
                 alignment: .center
             )
             .padding(.horizontal)
             .padding(.bottom)

             ServxInputView(
                 text: $viewModel.email,
                 placeholder: "Email",
                 frameColor: ServxTheme.inputFieldBorderColor,
                 backgroundColor: ServxTheme.backgroundColor,
                 textColor: ServxTheme.secondaryTextColor,
                 keyboardType: .emailAddress,
             )
             .padding(.horizontal)

            VStack {
                 if viewModel.isLoading {
                     ProgressView()
                         .padding(.top)
                 } else if let error = viewModel.errorMessage {
                     Text(error)
                         .foregroundColor(.red)
                         .font(.footnote)
                         .multilineTextAlignment(.center)
                         .padding(.horizontal)
                         .padding(.top)
                 } else if let success = viewModel.successMessage {
                     Text(success)
                         .foregroundColor(.green)
                         .font(.footnote)
                         .multilineTextAlignment(.center)
                         .padding(.horizontal)
                         .padding(.top)
                 }
            }
            .frame(minHeight: 50)


            Spacer()

            ServxButtonView(
                title: "Send Reset Link",
                width: 342,
                height: 56,
                frameColor: viewModel.isFormValid ? ServxTheme.linkTextColor : ServxTheme.buttonDisabledColor,
                innerColor: viewModel.isFormValid ? ServxTheme.linkTextColor : ServxTheme.buttonDisabledColor,
                textColor: ServxTheme.backgroundColor,
                isDisabled: !viewModel.isFormValid || viewModel.isLoading,
                action: {
                    Task {
                         await viewModel.forgotPassword()
                    }
                }
            )
            .padding(.bottom)

        }
        .navigationBarBackButtonHidden(true)
    }
}
