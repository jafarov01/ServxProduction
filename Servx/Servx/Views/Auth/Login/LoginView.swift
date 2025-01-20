//
//  AuthenticationView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject private var navigationManager: NavigationManager

    // Dependency Injection for ViewModel
    init(viewModel: @autoclosure @escaping () -> LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(spacing: 32) {
            // Navigation Header
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

            // Title
            ServxTextView(
                text: "Login to your Account",
                color: ServxTheme.primaryColor,
                size: 24,
                weight: .bold,
                alignment: .center
            )
            .padding(.top, 40)

            // Input Fields
            VStack(spacing: 24) {
                ServxInputView(
                    text: $viewModel.email,
                    placeholder: "Email",
                    frameColor: ServxTheme.inputFieldBorderColor,
                    backgroundColor: ServxTheme.backgroundColor,
                    textColor: ServxTheme.secondaryTextColor,
                    keyboardType: .emailAddress
                )
                .onAppear {
                    if UserDefaultsManager.rememberMe {
                        viewModel.email = UserDefaultsManager.rememberedEmail ?? ""
                    }
                }

                ServxInputView(
                    text: $viewModel.password,
                    placeholder: "Password",
                    isSecure: true,
                    frameColor: ServxTheme.inputFieldBorderColor,
                    backgroundColor: ServxTheme.backgroundColor,
                    textColor: ServxTheme.secondaryTextColor
                )

                // Remember Me Toggle
                Toggle(isOn: $viewModel.isRememberMe) {
                    ServxTextView(
                        text: "Remember me",
                        color: ServxTheme.blackColor,
                        size: 16,
                        weight: .regular
                    )
                }
                .toggleStyle(.switch)
                .padding(.horizontal, 2)
            }

            // Buttons
            VStack(spacing: 16) {
                // Sign-In Button
                ServxButtonView(
                        title: "Sign in",
                        width: 342,
                        height: 56,
                        frameColor: viewModel.isFormValid ? ServxTheme.linkTextColor : ServxTheme.greyScale400Color,
                        innerColor: viewModel.isFormValid ? ServxTheme.linkTextColor : ServxTheme.greyScale400Color,
                        textColor: ServxTheme.backgroundColor,
                        isDisabled: !viewModel.isFormValid,
                        action: {
                            viewModel.handleRememberMe()
                            viewModel.login { success in
                                if success {
                                    navigationManager.navigate(to: .home)
                                }
                            }
                        }
                    )
                    .opacity(viewModel.isFormValid ? 1 : 0.6) // Reduce opacity for disabled state

                // Forgot Password
                ServxButtonView(
                    title: "Forgot the password?",
                    width: 342,
                    height: 40,
                    frameColor: .clear,
                    innerColor: .clear,
                    textColor: ServxTheme.linkTextColor,
                    font: .subheadline,
                    action: {
                        navigationManager.navigate(to: .forgotPassword)
                    }
                )
            }

            // Social Login
            ServiceAuthView(hasAccount: true)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .navigationBarBackButtonHidden(true)
    }
}
