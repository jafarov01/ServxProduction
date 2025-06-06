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
    func updateUserDetails(_ request: UpdateUserRequest) async throws -> UserResponse
    func upgradeToProvider(request: UpgradeToProviderRequestDTO) async throws -> UserResponse
}

final class UserService: UserServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func upgradeToProvider(request: UpgradeToProviderRequestDTO) async throws -> UserResponse {
        let endpoint = Endpoint.upgradeToProvider(request: request)
        let response: UserResponse = try await apiClient.request(endpoint)
        return response
    }
    
    /// Retrieves the current user's details.
    func getUserDetails() async throws -> UserResponse {
        return try await apiClient.request(.getUserDetails)
    }
    
    func updateUserDetails(_ request: UpdateUserRequest) async throws -> UserResponse {
            return try await apiClient.request(
                .updateUserDetails(request: request)
            )
        }
    
    /// Uploads a new profile photo. Returns a URL for the new profile photo.
    func updateProfilePhoto(_ image: UIImage) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkError.invalidImageData
        }

        let response: ProfilePhotoResponse = try await apiClient.upload(
            endpoint: .updateProfilePhoto,
            fileData: imageData,
            fileName: "profile.jpg",
            mimeType: "image/jpeg"
        )

        // Validates URL construction
        guard let url = response.fullURL() else {
            print("""
            🚨 Invalid URL Construction:
               - Base: http://localhost:8080
               - Path: \(response.url)
            """)
            throw NetworkError.invalidURLFormat
        }
        
        print("✅ Valid Profile Photo URL: \(url.absoluteString)")
        return url
    }
    
    /// Deletes the current user's profile photo.
    func deleteProfilePhoto() async throws {
        // the request throws if there is any error.
        let _: DeletePhotoResponse = try await apiClient.request(.deleteProfilePhoto)
    }
}
