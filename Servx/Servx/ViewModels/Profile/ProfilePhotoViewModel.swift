//
//  ProfilePhotoViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 14..
//

import Foundation
import Combine

@MainActor
class ProfilePhotoViewModel: ObservableObject {
    @Published private(set) var user: User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        AuthenticatedUser.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
}
