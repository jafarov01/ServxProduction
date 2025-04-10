//
//  MoreViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

class MoreViewModel: ObservableObject {
    @Published var user: User?
    private let service: UserServiceProtocol
    
    init(service: UserServiceProtocol = UserService()) {
        self.service = service
    }
    
    func loadUser() {
        Task {
            do {
                let user = try await service.getUserDetails()
                await MainActor.run { self.user = user.toEntity() }
            } catch {
                print("Error loading user: \(error)")
            }
        }
    }
}
