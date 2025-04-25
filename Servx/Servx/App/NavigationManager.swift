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
enum AppRoute {
    enum Login: Hashable {
        case onboarding
        case authentication
        case register
        case forgotPassword
    }
    
    enum More: Hashable {
        case profile
        case editProfile
        case photoEdit
        case settings
        case support
        case becomeProvider
        case manageServices
    }
    
    enum Main: Hashable {
        case category(ServiceCategory)
        case subcategory(ServiceArea)
        case serviceRequest(ServiceProfile)
        case notifications
        case serviceRequestDetail(id: Int64)  // For NEW_REQUEST/REQUEST_ACCEPTED
        case serviceReview(bookingId: Int64)  // For SERVICE_COMPLETED
        case serviceProfileDetail(ServiceProfile)
        case searchView(searchTerm: String)
    }
    
    enum Inbox: Hashable {
        case chat(requestId: Int64)
    }
    
    enum BookingTab: Hashable { // Routes specific to Booking tab's stack
        case leaveReview(bookingId: Int64, providerName: String, serviceName: String)
     }
}

enum Tab: String, CaseIterable {
    case home, booking, calendar, inbox, more
}

// MARK: - Navigation Manager
@MainActor
final class NavigationManager: ObservableObject {
    // MARK: - Navigation Stacks
    @Published var mainStack = NavigationPath()
    @Published var authStack = NavigationPath()
    @Published var moreStack = NavigationPath()
    @Published var inboxStack = NavigationPath()
    @Published var bookingStack = NavigationPath()
    @Published var selectedTab: Tab = .home
    @Published var isSplashVisible = true
    
    // MARK: - Dependencies
    private let userSession: UserSessionManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(userSession: UserSessionManager) {
        self.userSession = userSession
        setupObservers()
        print("✅ NavigationManager initialized")
    }
    
    // MARK: - Public Interface
    func navigate(to route: any Hashable) {
        switch route {
        case let route as AppRoute.Login:
            authStack.append(route)
        case let route as AppRoute.More:
            moreStack.append(route)
        case let route as AppRoute.Main:
            mainStack.append(route)
        case let route as AppRoute.Inbox:
            inboxStack.append(route)
        case let route as AppRoute.BookingTab:
            bookingStack.append(route)
        default:
            logError("Attempted to navigate to invalid route type: \(type(of: route))")
        }
        logNavigation(route)
    }
    
    func switchTab(to tab: Tab) {
        guard selectedTab != tab else { return }
        selectedTab = tab
        resetAllStacks()
    }
    
    func navigateToChat(requestId: Int64) {
        // Switch to Inbox tab
        selectedTab = .inbox
        
        // Clear existing navigation stack
        inboxStack.removeLast(inboxStack.count)
        
        // Navigate to chat view
        navigate(to: AppRoute.Inbox.chat(requestId: requestId));
    }
    
    func goBack() {
        if !mainStack.isEmpty {
            mainStack.removeLast()
        } else if !authStack.isEmpty {
            authStack.removeLast()
        } else if !moreStack.isEmpty {
            moreStack.removeLast()
        } else if !inboxStack.isEmpty {
            inboxStack.removeLast()
        } else if !bookingStack.isEmpty {
            bookingStack.removeLast()
        }
    }
    
    func resetAllStacks() {
        bookingStack.removeLast(bookingStack.count)
        authStack.removeLast(authStack.count)
        moreStack.removeLast(moreStack.count)
        mainStack.removeLast(mainStack.count)
        inboxStack.removeLast(inboxStack.count)
    }
    
    func setupInitialNavigation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isSplashVisible = false
            self?.handleInitialAuthState()
        }
    }
}

// MARK: - Private Implementation
private extension NavigationManager {
    private func setupObservers() {
        userSession.$authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .authenticated:
                    self?.handleAuthenticatedState()
                case .unauthenticated:
                    self?.handleUnauthenticatedState()
                case .unknown:
                    self?.handleUnknownState()
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleInitialAuthState() {
        switch userSession.authState {
        case .authenticated:
            handleAuthenticatedState()
        case .unauthenticated:
            handleUnauthenticatedState()
        case .unknown:
            handleUnknownState()
        }
    }

    private func handleAuthenticatedState() {
        resetAllStacks()
        logNavigation("User authenticated")
    }

    private func handleUnauthenticatedState() {
        navigate(to: AppRoute.Login.authentication)
        logNavigation("User unauthenticated")
    }

    private func handleUnknownState() {
        logNavigation("Auth state unknown")
    }
    
    func resetMainStack() {
        mainStack = .init()
    }
}

// MARK: - Logging
private extension NavigationManager {
    func logNavigation(_ message: String) {
        print("🧭 \(message)")
    }
    
    func logNavigation(_ route: some Hashable) {
        print("🧭 Navigating to: \(String(describing: route))")
        print("""
        Current Stacks:
        - Main: \(mainStack.count) items
        - Auth: \(authStack.count) items
        - More: \(moreStack.count) items
        """)
    }
    
    func logError(_ message: String) {
        print("🚨 Navigation Error: \(message)")
    }
}
