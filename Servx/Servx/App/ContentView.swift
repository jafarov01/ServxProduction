//
//  ContentView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userSessionManager = UserSessionManager(userDetailsService: UserDetailsService())
    @StateObject private var navigationManager = NavigationManager(userSessionManager: UserSessionManager(userDetailsService: UserDetailsService()))

    var body: some View {
        ZStack {
            if navigationManager.isSplashVisible {
                SplashScreenView()
                    .onAppear {
                        // Ensure that navigationManager's setup is called once navigationManager is fully initialized
                        navigationManager.setupInitialNavigation()
                    }
            } else {
                NavigationStack(path: $navigationManager.path) {
                    EmptyView()
                        .navigationDestination(for: AppView.self) { view in
                            switch view {
                            case .onboarding:
                                OnboardingView()
                            case .authentication:
                                LoginView(viewModel: LoginViewModel(authService: AuthService(), userDetailsService: UserDetailsService()))
                            case .home:
                                HomeView(viewModel: HomeViewModel())
                            case .register:
                                RegisterView(viewModel: RegisterViewModel(authService: AuthService()))
                            case .forgotPassword:
                                ForgotPasswordView()
                            case .subcategories(let category):
                                SubcategoriesListView(category: category, viewModel: SubcategoriesViewModel(category: category))
                            case .services(let subcategory):
                                ServicesListView(subcategory: subcategory, viewModel: ServicesViewModel(subcategory: subcategory))
                            }
                        }
                }
            }
        }
        .environmentObject(navigationManager)
    }
}
