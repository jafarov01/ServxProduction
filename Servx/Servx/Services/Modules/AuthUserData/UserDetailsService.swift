//
//  UserDetailsService.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 01..
//

final class UserDetailsService: UserDetailsServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func getUserDetails() async throws -> UserDetailsResponse {
        do {
            return try await apiClient.request(.getUserDetails)
        } catch let error as NetworkError {
            print("User details fetch failed: \(error.localizedDescription)")
            throw error
        } catch {
            throw NetworkError.unknown
        }
    }
}
