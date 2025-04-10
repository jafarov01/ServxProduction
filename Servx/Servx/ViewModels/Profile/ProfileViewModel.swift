//
//  ProfileViewViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//

// ProfileViewModel encapsulates profile data and operations (in the same file for simplicity)
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    var isLoading : Bool = false
    var errorMessage : String = ""
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func loadUser() async {
        isLoading = true
        do {
            let response = try await userService.getUserDetails()
            let user = response.toEntity()
            await MainActor.run {
                self.user = user
                AuthenticatedUser.shared.updateUser(user: user)
            }
        } catch {
            errorMessage = "Failed to load user: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
