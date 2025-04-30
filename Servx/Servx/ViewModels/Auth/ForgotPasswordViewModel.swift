//
//  ForgotPasswordViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import SwiftUI

@MainActor
class ForgotPasswordViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    var isFormValid: Bool {
        !email.isEmpty && email.contains("@")
    }

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func forgotPassword() async {
        guard isFormValid else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            try await authService.requestPasswordReset(email: email)
            successMessage = "If an account exists for \(email), a password reset link has been sent. Please check your inbox (and spam folder)."
        } catch let error as NetworkError {
            errorMessage = "Network Error: \(error.localizedDescription)"
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
