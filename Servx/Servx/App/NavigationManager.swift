//
//  NavigationManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import SwiftUI

enum AppView: Hashable {
    case forgotPassword
    case onboarding
    case authentication
    case home
    case register
    case subcategories(category: ServiceCategory)
    case services(subcategory: Subcategory)
}

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    @Published var isSplashVisible = true

    private let userSessionManager: UserSessionManager

    init(userSessionManager: UserSessionManager) {
        self.userSessionManager = userSessionManager
    }

    func setupInitialNavigation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.userSessionManager.isAuthenticated {
                // If the user is authenticated, navigate to home
                self.path.append(AppView.home)
            } else {
                // If not authenticated, navigate to authentication
                self.path.append(AppView.authentication)
            }
            self.isSplashVisible = false
        }
    }

    func navigate(to view: AppView) {
        path.append(view)
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func reset() {
        path.removeLast(path.count)
    }
}
