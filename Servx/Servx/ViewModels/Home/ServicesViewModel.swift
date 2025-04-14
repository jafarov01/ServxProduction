//
//  ServicesViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import Foundation
import Combine

@MainActor
class ServicesViewModel: ObservableObject {
    @Published private(set) var services: [ServiceProfile] = []
    @Published private(set) var filteredServices: [ServiceProfile] = []
    @Published var searchQuery = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let service: ServicesServiceProtocol
    let subcategory: ServiceArea
    private var cancellables = Set<AnyCancellable>()
    
    init(subcategory: ServiceArea, service: ServicesServiceProtocol = ServicesService()) {
        self.subcategory = subcategory
        self.service = service
        setupObservers()
    }

    private func setupObservers() {
        $searchQuery
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterServices()
            }
            .store(in: &cancellables)
    }

    func loadServices() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedServices = try await service.fetchServices(
                categoryId: subcategory.categoryId,
                subcategoryId: subcategory.id
            )
            services = fetchedServices
            filteredServices = fetchedServices
        } catch {
            errorMessage = "Failed to load services. Please try again."
        }
    }

    private func filterServices() {
        guard !searchQuery.isEmpty else {
            filteredServices = services
            return
        }
        
        filteredServices = services.filter {
            $0.serviceTitle.localizedCaseInsensitiveContains(searchQuery) ||
            $0.providerName.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}
