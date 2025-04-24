//
//  AuthenticatedUser.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import Foundation

@MainActor
final class AuthenticatedUser: ObservableObject {
    static let shared = AuthenticatedUser()
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var requiresOnboarding = true
    
    private init() {}
    
    var fullName: String {
        [currentUser?.firstName, currentUser?.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    func authenticate(with response: UserResponse) {
        var updated = response.toEntity()
        
        if var url = updated.profilePhotoUrl {
            url = url.appending(queryItems: [
                URLQueryItem(name: "t", value: UUID().uuidString)
            ])
            updated.profilePhotoUrl = url
        }

        currentUser = updated
        isAuthenticated = true
        requiresOnboarding = false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        requiresOnboarding = true
    }
}
