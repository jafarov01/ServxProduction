//
//  ProfilePhotoEditViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//

import SwiftUI
import UIKit

class ProfilePhotoEditViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }

    // Select a new photo from library or camera
    func selectNewPhoto(_ image: UIImage) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedPhotoURL = try await userService.updateProfilePhoto(image)
            AuthenticatedUser.shared.updateProfilePhoto(url: updatedPhotoURL.absoluteString)
            isLoading = false
        } catch {
            errorMessage = "Failed to update photo: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // Remove profile photo
    func removeProfilePhoto() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await userService.deleteProfilePhoto()
            AuthenticatedUser.shared.updateProfilePhoto(url: nil)
            isLoading = false
        } catch {
            errorMessage = "Failed to delete photo: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
