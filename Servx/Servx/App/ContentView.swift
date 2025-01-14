//
//  ContentView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager()

    // View Models for DI
    @StateObject private var loginViewModel = LoginViewModel(authService: AuthService())
    @StateObject private var registerViewModel = RegisterViewModel()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            SplashScreenView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        navigationManager.setupInitialNavigation()
                    }
                }
                .navigationDestination(for: AppView.self) { view in
                    switch view {
                    case .onboarding:
                        OnboardingView()
                    case .authentication:
                        LoginView(viewModel: loginViewModel)
                    case .home:
                        HomeView()
                    case .register:
                        RegisterView(viewModel: registerViewModel)
                    case .subcategories(let category):
                        SubcategoriesView(category: category)
                    case .services(let category, let subcategory):
                        ServicesView(category: category, subcategory: subcategory)
                    case .forgotPassword:
                        ForgotPasswordView()
                    }
                }
        }
        .environmentObject(navigationManager)
    }
}
