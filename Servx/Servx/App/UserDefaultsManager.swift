//
//  UserDefaultsManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import Foundation

struct UserDefaultsManager {
    private enum Keys: String {
        case hasCompletedOnboarding
        case rememberMe
        case rememberedEmail
    }
    
    static var shouldShowOnboarding: Bool {
        get { !UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding.rawValue) }
        set { UserDefaults.standard.set(!newValue, forKey: Keys.hasCompletedOnboarding.rawValue) }
    }

    static var rememberMe: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.rememberMe.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.rememberMe.rawValue) }
    }
    
    static var rememberedEmail: String? {
        get { UserDefaults.standard.string(forKey: Keys.rememberedEmail.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.rememberedEmail.rawValue) }
    }
}
