//
//  LoginViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isRememberMe: Bool = false
    @Published var isFormValid: Bool = false
    @Published var isLoading: Bool = false
    @Published var loginSuccess = false
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest(
            $email.map { !$0.isEmpty && $0.contains("@") },
            $password.map { $0.count >= 6 }
        )
        .map { $0 && $1 }
        .receive(on: DispatchQueue.main)
        .assign(to: &$isFormValid)
    }
    
    func login() {
        guard isFormValid else { return }
        
        isLoading = true
        Task {
            do {
                try await authService.login(email: email, password: password)
                loginSuccess = true
            } catch {
                handleLoginError(error)
            }
            isLoading = false
        }
    }
    
    private func handleLoginError(_ error: Error) {
        print("Login failed: \(error.localizedDescription)")
    }
    
    func handleRememberMe() {
        UserDefaultsManager.rememberedEmail = isRememberMe ? email : nil
        UserDefaultsManager.rememberMe = isRememberMe
    }
}
