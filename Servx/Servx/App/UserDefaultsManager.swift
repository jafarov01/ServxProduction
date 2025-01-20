//
//  UserDefaultsManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import Foundation
import SwiftUI

struct UserDefaultsManager {
    private enum Keys: String {
        case firstLaunch = "hasLaunchedBefore"
        case isAuthenticated
        case authToken
        case userEmail
        case userRole
        case rememberMe
        case rememberedEmail
    }
    
    // MARK: - First Launch Management
    static var isFirstLaunch: Bool {
        get {
            let hasLaunched = UserDefaults.standard.bool(forKey: Keys.firstLaunch.rawValue)
            if !hasLaunched {
                UserDefaults.standard.set(true, forKey: Keys.firstLaunch.rawValue)
                return true
            }
            return false
        }
    }

    // MARK: - Authentication State
    static var isAuthenticated: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.isAuthenticated.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isAuthenticated.rawValue)
        }
    }

    // MARK: - Auth Token
    static var authToken: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.authToken.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.authToken.rawValue)
        }
    }

    // MARK: - User Email
    static var userEmail: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.userEmail.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.userEmail.rawValue)
        }
    }

    // MARK: - User Role
    static var userRole: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.userRole.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.userRole.rawValue)
        }
    }

    // MARK: - Remember Me
    static var rememberMe: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.rememberMe.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.rememberMe.rawValue)
        }
    }
    
    // MARK: - Remembered Email
    static var rememberedEmail: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.rememberedEmail.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.rememberedEmail.rawValue)
        }
    }

    // MARK: - Clear All User Data
    static func clearUserData() {
        let keysToClear: [Keys] = [.isAuthenticated, .authToken, .userEmail, .userRole, .rememberMe]
        keysToClear.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
}
