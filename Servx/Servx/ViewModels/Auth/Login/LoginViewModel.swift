//
//  LoginViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import Foundation
import Combine

/// ViewModel for managing login logic and validation state
@MainActor
class LoginViewModel: ObservableObject {
    // Input Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isRememberMe: Bool = false
    
    // Validation State
    @Published var isFormValid: Bool = false
    @Published var isLoading: Bool = false
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Dependency Injection
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        setupValidation()
    }
    
    // Setup Validation
    func setupValidation() {
        Publishers.CombineLatest(
            $email.map { !$0.isEmpty && $0.contains("@") },
            $password.map { $0.count >= 6 }
        )
        .map { $0 && $1 }
        .receive(on: DispatchQueue.main)
        .assign(to: &$isFormValid)
    }
    
    // MARK: - Load Remembered Credentials
    /// Loads remembered email into the ViewModel if "Remember Me" is enabled
    private func loadRememberedCredentials() {
        if isRememberMe, let rememberedEmail = UserDefaultsManager.rememberedEmail {
            email = rememberedEmail
        }
    }
    
    // MARK: - Handle Remember Me
    /// Handles "Remember Me" functionality
    func handleRememberMe() {
        if isRememberMe {
            UserDefaultsManager.rememberedEmail = email
        } else {
            UserDefaultsManager.rememberedEmail = nil
        }
        UserDefaultsManager.rememberMe = isRememberMe
    }
    
    // MARK: - Login Action
    /// Handles the login process
    func login(completion: @escaping (Bool) -> Void) {
        guard isFormValid else { return }
        
        isLoading = true
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let authResponse = try await self.authService.login(email: self.email, password: self.password)
                UserDefaultsManager.authToken = authResponse.token
                UserDefaultsManager.userRole = authResponse.role
                self.isLoading = false
                completion(true)
            } catch {
                self.isLoading = false
                completion(false)
            }
        }
    }
}
