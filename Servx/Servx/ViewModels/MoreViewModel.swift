//
//  MoreViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI
import Combine

@MainActor
class MoreViewModel: ObservableObject {
    @Published private(set) var user: User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    func setupObservers() {
        AuthenticatedUser.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
}
