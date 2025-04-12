//
//  ServicesViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import Foundation

// ServicesViewModel: Retrieves services for a selected subcategory and handles search.
@MainActor
class ServicesViewModel: ObservableObject {
    @Published var services: [ServiceProfile] = []
    @Published var filteredServices: [ServiceProfile] = []
    @Published var searchQuery = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: ServicesServiceProtocol
    let subcategory: ServiceArea

    init(subcategory: ServiceArea, service: ServicesServiceProtocol = ServicesService()) {
        self.subcategory = subcategory
        self.service = service
        setupSearchListener()
    }

    private func setupSearchListener() {
        Task {
            for await query in $searchQuery.values {
                filterServices(query: query)
            }
        }
    }

    func loadServices() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Fetch services from the API
            let fetchedServices = try await service.fetchServices(
                categoryId: subcategory.categoryId,
                subcategoryId: subcategory.id
            )

            // Assign the fetched services to `services` and `filteredServices`
            self.services = fetchedServices
            self.filteredServices = fetchedServices
        } catch {
            errorMessage = "Failed to load services. Please try again."
            print("Error fetching services: \(error.localizedDescription)")
        }
    }

    private func filterServices(query: String) {
        // Guard against empty search query
        guard !query.isEmpty else {
            filteredServices = services
            return
        }

        // Filter services by matching query against serviceTitle or providerName (both case-insensitive)
        filteredServices = services.filter { service in
            service.serviceTitle.localizedCaseInsensitiveContains(query) ||
            service.providerName.localizedCaseInsensitiveContains(query)
        }
    }
}
