//
//  UnauthenticatedFlowView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 05..
//


import SwiftUI

struct UnauthenticatedFlowView: View {
    @EnvironmentObject private var navManager: NavigationManager
    
    var body: some View {
        NavigationStack(path: $navManager.authStack) {
            LoginView(
                viewModel: LoginViewModel(
                    authService: AuthService(),
                )
            )
            .navigationDestination(for: AppRoute.Login.self) { route in
                switch route {
                case .onboarding:
                    OnboardingView()
                        .transition(.slide)
                    
                case .authentication:
                    LoginView(
                        viewModel: LoginViewModel(
                            authService: AuthService(),
                        )
                    )
                    
                case .register:
                    RegisterView(
                        viewModel: RegisterViewModel(
                            authService: AuthService()
                        )
                    )
                    .transition(.move(edge: .trailing))
                    
                case .forgotPassword:
                    ForgotPasswordView()
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            if !navManager.authStack.isEmpty {
                navManager.authStack.removeLast(navManager.authStack.count)
            }
        }
    }
}
