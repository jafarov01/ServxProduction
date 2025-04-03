//
//  ForgotPasswordView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import SwiftUI

import Foundation
import SwiftUI

struct ForgotPasswordView: View {
    
    @StateObject var viewModel = ForgotPasswordViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject private var loginViewModel = LoginViewModel(authService: AuthService(), userDetailsService: UserDetailsService())
        
    var body: some View {
        
        VStack(content: {
            
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
            
            HStack(alignment: .center) {
                ServxTextView(
                    text: "Forgot Password",
                    color: ServxTheme.primaryColor,
                    size: 24,
                    weight: .bold,
                    alignment: .center
                )
                
//                Image("authKeyImage")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 24, height: 24)
//                    .padding(.leading, 35)
            }
            
            
            ServxTextView(
                text: "Enter your email adress to get an email to reset your password",
                color: ServxTheme.blackColor,
                size: 16,
                weight: .bold,
                alignment: .center
            )
            .padding()
            
            ServxInputView(
                text: $viewModel.email,
                placeholder: "Email",
                frameColor: ServxTheme.inputFieldBorderColor,
                backgroundColor: ServxTheme.backgroundColor,
                textColor: ServxTheme.secondaryTextColor,
                keyboardType: .emailAddress
            )
            .padding()
            
            Spacer()
            
            ServxTextView(
                text: "Please, reset your password using the link sent to your email, after clicking the button below",
                color: ServxTheme.greyScale400Color,
                size: 16,
                weight: .bold,
                alignment: .center
            )
            .padding()
            
            
            ServxButtonView(
                title: "Reset Password",
                width: 342,
                height: 56,
                frameColor: viewModel.isFormValid ? ServxTheme.linkTextColor : ServxTheme.buttonDisabledColor,
                innerColor: viewModel.isFormValid ? ServxTheme.linkTextColor : ServxTheme.buttonDisabledColor,
                textColor: ServxTheme.backgroundColor,
                isDisabled: !viewModel.isFormValid,
                action: {
                    viewModel.forgotPassword()
                    navigationManager.navigate(to: .authentication)
                }
            )
        })
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    ForgotPasswordView()
}
