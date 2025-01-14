//
//  LoginViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 12. 01..
//

import Combine
import Foundation

class LoginViewModel: ObservableObject {
    // Input Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isRememberMe: Bool = false

    // Validation State
    @Published var isFormValid: Bool = false
    @Published var errorMessage: String? = nil
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
        .assign(to: &$isFormValid)
    }

    // Login Action
    func login(completion: @escaping (Bool) -> Void) {
        guard isFormValid else {
            errorMessage = "Invalid credentials. Please check your input."
            completion(false)
            return
        }

        isLoading = true
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                // Assuming a successful login if a token is received
                if !response.token.isEmpty {
                    completion(true)
                } else {
                    self.errorMessage = "Login failed. Invalid credentials."
                    completion(false)
                }
            })
            .store(in: &cancellables)
    }
}
