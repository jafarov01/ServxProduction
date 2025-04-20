//
//  ServicesViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//


import SwiftUI
import Combine

@MainActor
class ServicesViewModel: ObservableObject {
    @Published private(set) var services: [ServiceProfile] = []
    @Published private(set) var filteredServices: [ServiceProfile] = []
    @Published var searchQuery = ""
    @Published private(set) var isLoading = false


    @Published var errorWrapper: ErrorWrapper? = nil



    private let service: ServicesServiceProtocol
    let subcategory: ServiceArea
    private var cancellables = Set<AnyCancellable>()

    init(subcategory: ServiceArea, service: ServicesServiceProtocol = ServicesService()) {
        self.subcategory = subcategory
        self.service = service
        print("ServicesViewModel initialized for subcategory: \(subcategory.name)")
        setupObservers()
    }

    private func setupObservers() {
        $searchQuery
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in // Capture query to use in print
                print("Filtering services based on query: \(query)")
                self?.filterServices()
            }
            .store(in: &cancellables)
    }

    func loadServices() async {
        guard !isLoading else { return }
        print("Loading services for subcategory: \(subcategory.name)")
        isLoading = true
        errorWrapper = nil // Clear error before loading
        defer { isLoading = false }

        do {
            let fetchedServices = try await service.fetchServices(
                categoryId: subcategory.categoryId,
                subcategoryId: subcategory.id
            )
            self.services = fetchedServices
            self.filterServices() // Apply initial filter
            print("Loaded \(fetchedServices.count) services.")
        } catch {
            let errorMsg = "Failed to load services. Please try again."
            print("Error loading services: \(error)")
            // --- CHANGE: Set errorWrapper ---
            self.errorWrapper = ErrorWrapper(message: errorMsg)
            // --- End Change ---
        }
    }

    private func filterServices() {
        if searchQuery.isEmpty {
            filteredServices = services
        } else {
            let lowercasedQuery = searchQuery.lowercased()
            filteredServices = services.filter { service in
                service.serviceTitle.lowercased().contains(lowercasedQuery) ||
                service.providerName.lowercased().contains(lowercasedQuery)
            }
        }
         print("Filtering complete. Filtered count: \(filteredServices.count)")
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID() // Conforms to Identifiable
    let message: String
}
