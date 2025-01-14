//
//  UserDefaultsManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import Foundation
import SwiftUI

struct UserDefaultsManager {
    private static let firstLaunchKey = "hasLaunchedBefore"

    static var isFirstLaunch: Bool {
        get {
            let hasLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
            if !hasLaunched {
                UserDefaults.standard.set(true, forKey: firstLaunchKey)
                return true
            }
            return false
        }
    }
    
    static var isAuthenticated: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isAuthenticated")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isAuthenticated")
        }
    }
}
