//
//  UserService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 07..
//

import Foundation
import UIKit

protocol UserServiceProtocol {
    func getUserDetails() async throws -> UserResponse
    func updateProfilePhoto(_ image: UIImage) async throws -> URL
    func deleteProfilePhoto() async throws
}

final class UserService: UserServiceProtocol {
    private let apiClient: APIClientProtocol
    
    // Dependency injection allows for testing or swapping with a mock client.
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    /// Retrieves the current user's details.
    func getUserDetails() async throws -> UserResponse {
        return try await apiClient.request(.getUserDetails)
    }
    
    /// Uploads a new profile photo. Returns a URL for the new profile photo.
    func updateProfilePhoto(_ image: UIImage) async throws -> URL {
        // Convert UIImage to JPEG data.
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkError.invalidResponse
        }
        
        // APIClient.upload will create a multipart/form-data request.
        let response: ProfilePhotoResponse = try await apiClient.upload(
            endpoint: .updateProfilePhoto,
            fileData: imageData,
            fileName: "profile.jpg",
            mimeType: "image/jpeg"
        )
        
        // Convert the returned URL string to URL.
        guard let url = URL(string: response.url) else {
            throw NetworkError.invalidResponse
        }
        return url
    }
    
    /// Deletes the current user's profile photo.
    func deleteProfilePhoto() async throws {
        // We do not need the response value here;
        // the request throws if there is any error.
        let _: DeletePhotoResponse = try await apiClient.request(.deleteProfilePhoto)
    }
}
