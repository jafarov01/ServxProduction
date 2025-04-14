//
//  ProfilePhotoEditViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

@MainActor
class ProfilePhotoEditViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func savePhoto(_ image: UIImage) async {
        isLoading = true
        do {
            // 1. Upload new photo
            let url = try await userService.updateProfilePhoto(image)
            
            // 2. Get updated user data
            let updatedUser = try await userService.getUserDetails()
            
            // 3. Update global authenticated user
            AuthenticatedUser.shared.authenticate(with: updatedUser)
            
        } catch {
            print("Error updating photo: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func removePhoto() async {
        isLoading = true
        do {
            // 1. Remove photo from server
            try await userService.deleteProfilePhoto()
            
            // 2. Get updated user data
            let updatedUser = try await userService.getUserDetails()
            
            // 3. Update global authenticated user
            AuthenticatedUser.shared.authenticate(with: updatedUser)
            
        } catch {
            print("Error removing photo: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
