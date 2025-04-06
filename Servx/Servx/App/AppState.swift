//
//  AppState.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 05..
//

import SwiftUI

enum AppState {
    case splash, unauthenticated, authenticated
}

class AppStateManager: ObservableObject {
    @Published var currentState: AppState = .splash
    @Published var isAuthenticated: Bool = false

    func setAuthenticated() {
        print("===== setAuthenticated called =====")
        self.isAuthenticated = true
        self.currentState = .authenticated
        print("AppState changed to authenticated")
        print("isAuthenticated: \(self.isAuthenticated), currentState: \(self.currentState)")
    }

    func setUnauthenticated() {
        print("===== setUnauthenticated called =====")
        self.isAuthenticated = false
        self.currentState = .unauthenticated
        print("AppState changed to unauthenticated")
        print("isAuthenticated: \(self.isAuthenticated), currentState: \(self.currentState)")
    }

    func showSplash() {
        print("===== showSplash called =====")
        self.currentState = .splash
        print("AppState changed to splash")
        print("currentState: \(self.currentState)")
    }
}
