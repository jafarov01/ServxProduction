//
//  NavigationManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//

import Foundation
import SwiftUI

enum AppView: Hashable {
    case forgotPassword
    case onboarding
    case authentication
    case home
    case register
}

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    func setupInitialNavigation() {
        reset()
        if UserDefaultsManager.isFirstLaunch {
            path.append(AppView.onboarding)
        } else if UserDefaultsManager.isAuthenticated {
            path.append(AppView.home)
        } else {
            path.append(AppView.authentication)
        }
    }
    
    func navigate(to view: AppView) {
        print("Navigating to: \(view)")
        self.path.append(view)
    }

    func goBack() {
        print("current path BEFORE: \(path.count)")
        if !path.isEmpty {
            print("going back if not empty")
            path.removeLast()
        }
        print("current path AFTER: \(path.count)")
    }

    func reset() {
        print("resetting nav path")
        path = NavigationPath()
    }
}
