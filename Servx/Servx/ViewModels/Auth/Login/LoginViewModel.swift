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
    
    private let authService: AuthServiceProtocol
    private let userDetailsService: UserDetailsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol, userDetailsService: UserDetailsServiceProtocol) {
        self.authService = authService
        self.userDetailsService = userDetailsService
        setupValidation()
    }
    
    func setupValidation() {
        Publishers.CombineLatest(
            $email.map { !$0.isEmpty && $0.contains("@") },
            $password.map { $0.count >= 6 }
        )
        .map { $0 && $1 }
        .receive(on: DispatchQueue.main)
        .assign(to: &$isFormValid)
    }
    
    func login(completion: @escaping (Bool) -> Void) {
            guard isFormValid else { return }

            isLoading = true
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    // Perform login and retrieve authResponse
                    _ = try await self.authService.login(email: self.email, password: self.password)
                    
                    // Fetch user details using the getUserDetails API call
                    let userDetails = try await self.userDetailsService.getUserDetails()

                    // Populate AuthenticatedUser with fetched user details
                    print("AuthenticaedUser is set")
                    AuthenticatedUser.shared.authenticateUser(from: userDetails)
                    
                    print("login success")
                    
                    self.isLoading = false
                    completion(true)
                } catch {
                    self.isLoading = false
                    completion(false)
                }
            }
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
}
