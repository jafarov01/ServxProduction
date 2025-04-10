//
//  ProfilePhotoEditViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

@MainActor
class ProfilePhotoEditViewModel: ObservableObject {
    @Published var isLoading = false
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func savePhoto(_ image: UIImage) async {
        isLoading = true
        do {
            let url = try await userService.updateProfilePhoto(image)
            AuthenticatedUser.shared.updateProfilePhoto(url: url)
            await MainActor.run {
                // Notify parent to refresh data
                NotificationCenter.default.post(name: .userDataUpdated, object: nil)
            }
        } catch {
            print("Error updating photo: \(error.localizedDescription)")
            // Show error alert
        }
        isLoading = false
    }

    func removePhoto() async {
        isLoading = true
        do {
            try await userService.deleteProfilePhoto()
            AuthenticatedUser.shared.updateProfilePhoto(url: nil)
            await MainActor.run {
                NotificationCenter.default.post(name: .userDataUpdated, object: nil)
            }
        } catch {
            print("Error removing photo: \(error.localizedDescription)")
            // Show error alert
        }
        isLoading = false
    }
}

// Add this extension
extension Notification.Name {
    static let userDataUpdated = Notification.Name("UserDataUpdatedNotification")
}
