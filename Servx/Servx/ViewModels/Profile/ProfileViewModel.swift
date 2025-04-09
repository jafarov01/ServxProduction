//
//  ProfileViewViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//

// ProfileViewModel encapsulates profile data and operations (in the same file for simplicity)
import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: UserResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }

    // Fetch user details
    func loadUserProfile() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedUser = try await userService.getUserDetails()
                await MainActor.run {
                    self.user = fetchedUser
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    // Refresh the user data
    func refreshUserData() {
        Task {
            do {
                let refreshedUser = try await userService.getUserDetails()
                await MainActor.run {
                    self.user = refreshedUser
                }
                AuthenticatedUser.shared.authenticateUser(from: refreshedUser) // Update AuthenticatedUser
            } catch {
                print("Failed to refresh user data: \(error.localizedDescription)")
            }
        }
    }
}
