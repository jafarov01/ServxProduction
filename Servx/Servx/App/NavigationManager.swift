//
//  NavigationManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import SwiftUI
import SwiftUI
import Combine

// MARK: - Navigation Routes
enum LoginRoute: Hashable {
    case onboarding
    case authentication
    case register
    case forgotPassword
}

enum ProfileRoute: Hashable {
    case edit
    case settings
    case support
}

enum Tab: String, CaseIterable {
    case home
    case booking
    case calendar
    case inbox
    case profile
}

// MARK: - Navigation Manager
@MainActor
final class NavigationManager: ObservableObject {
    // MARK: - Published Properties
    @Published var mainPath = NavigationPath()    // Main app navigation stack
    @Published var authPath = NavigationPath()   // Authentication flow stack
    @Published var profilePath = NavigationPath() // Profile navigation stack
    @Published var selectedTab: Tab = .home
    @Published var isAuthenticated = false
    @Published var isSplashVisible = true
    
    // MARK: - Dependencies
    private let userSessionManager: UserSessionManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(userSessionManager: UserSessionManager) {
        self.userSessionManager = userSessionManager
        setupObservers()
        print("✅ NavigationManager initialized")
    }
    
    // MARK: - Public Interface
    
    /// Main app navigation actions
    func navigateTo(_ category: ServiceCategory) {
        mainPath.append(category)
        logNavigation("ServiceCategory: \(category.name)")
    }
    
    func navigateTo(_ subcategory: Subcategory) {
        mainPath.append(subcategory)
        logNavigation("Subcategory: \(subcategory.name)")
    }
    
    /// Authentication flow navigation
    func navigateTo(_ route: LoginRoute) {
        authPath.append(route)
        logNavigation("LoginRoute: \(route)")
    }
    
    func navigateTo(_ route: ProfileRoute) {
        profilePath.append(route)
        logNavigation("ProfileRoute: \(route)")
    }
    
    func switchTab(to tab: Tab) {
        guard selectedTab != tab else { return }
        selectedTab = tab
        resetMainNavigation()
        print("🔀 Switched to tab: \(tab.rawValue)")
    }
    
    func goBack() {
        if !mainPath.isEmpty {
            mainPath.removeLast()
            print("↩️ Main navigation back")
        } else if !authPath.isEmpty {
            authPath.removeLast()
            print("↩️ Auth navigation back")
        }
    }
    
    func resetAllNavigation() {
        mainPath = NavigationPath()
        profilePath = NavigationPath()
        authPath = NavigationPath()
        print("🔄 Reset all navigation stacks")
    }
    
    // MARK: - Initial Setup
    func setupInitialNavigation() {
        print("🚀 Setting up initial navigation...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }
            
            self.isSplashVisible = false
            
            if self.userSessionManager.isAuthenticated {
                self.handleAuthenticatedState()
            } else {
                self.handleUnauthenticatedState()
            }
        }
    }
    
    func resetMainNavigation() {
        mainPath = NavigationPath()
        print("🔄 Reset main navigation stack")
    }
    
    func resetProfileNavigation() {
        profilePath = NavigationPath()
        print("🔄 Reset profile navigation stack")
    }
}

// MARK: - Private Implementation
private extension NavigationManager {
    func handleAuthenticatedState() {
        isAuthenticated = true
        print("🔓 User authenticated")
    }
    
    func handleUnauthenticatedState() {
        isAuthenticated = false
        navigateTo(.authentication)
        print("🔒 User unauthenticated")
    }
    
    func setupObservers() {
        userSessionManager.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                guard let self else { return }
                self.isAuthenticated = isAuthenticated
                if isAuthenticated {
                    self.resetAllNavigation()
                }
            }
            .store(in: &cancellables)
    }
    
    func logNavigation(_ message: String) {
        print("🧭 Navigation: \(message)")
        print("Main Path: \(String(describing: mainPath))")
        print("Auth Path: \(String(describing: authPath))")
        print("Profile Path: \(String(describing: profilePath))")
    }
}
