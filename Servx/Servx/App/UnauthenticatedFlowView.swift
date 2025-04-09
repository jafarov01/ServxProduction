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
        NavigationStack(path: $navManager.authPath) {
            LoginView(
                viewModel: LoginViewModel(
                    authService: AuthService(),
                    userService: UserService()
                )
            )
            .navigationDestination(for: LoginRoute.self) { route in
                switch route {
                case .onboarding:
                    OnboardingView()
                        .transition(.slide)
                    
                case .authentication:
                    LoginView(
                        viewModel: LoginViewModel(
                            authService: AuthService(),
                            userService: UserService()
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
            // Clear any previous navigation state when flow appears
            if !navManager.authPath.isEmpty {
                navManager.authPath.removeLast(navManager.authPath.count)
            }
        }
    }
}
