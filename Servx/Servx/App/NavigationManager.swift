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

enum MoreRoute: Hashable {
    case profile
    case editProfile
    case photoEdit
    case settings
    case support
    case becomeProvider
    case manageServices
}

enum Tab: String, CaseIterable {
    case home
    case booking
    case calendar
    case inbox
    case more
}

// MARK: - Navigation Manager
@MainActor
final class NavigationManager: ObservableObject {
    // MARK: - Published Properties
    @Published var mainPath = NavigationPath()    // Main app navigation stack
    @Published var authPath = NavigationPath()   // Authentication flow stack
    @Published var morePath = NavigationPath()
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
    
    func navigateTo(_ subcategory: ServiceArea) {
        mainPath.append(subcategory)
        logNavigation("Subcategory: \(subcategory.name)")
    }
    
    /// Authentication flow navigation
    func navigateTo(_ route: LoginRoute) {
        authPath.append(route)
        logNavigation("LoginRoute: \(route)")
    }
    
    func navigateTo(_ route: MoreRoute) {
        morePath.append(route)
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
        } else if !morePath.isEmpty {
            morePath.removeLast()
            print("↩️ More navigation back")
        }
    }
    
    func resetAllNavigation() {
        mainPath = NavigationPath()
        morePath = NavigationPath()
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
        print("More Path: \(String(describing: morePath))")
    }
}
