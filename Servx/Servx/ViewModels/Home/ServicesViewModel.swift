//
//  ServicesViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import Foundation


//ServicesViewModel: Retrieves services for a selected subcategory and handles search.
@MainActor
class ServicesViewModel: ObservableObject {
    @Published var services: [ServiceProfile] = []
    @Published var filteredServices: [ServiceProfile] = []
    @Published var searchQuery = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: ServicesServiceProtocol
    let subcategory: Subcategory

    init(subcategory: Subcategory, service: ServicesServiceProtocol = ServicesService()) {
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
            var fetchedServices = try await service.fetchServices(
                categoryId: subcategory.categoryId,
                subcategoryId: subcategory.id
            )

            // Set the service title to subcategory name
            for index in fetchedServices.indices {
                fetchedServices[index].serviceTitle = subcategory.name
            }

            // Fetch provider names
            for index in fetchedServices.indices {
                if let userId = fetchedServices[index].userId {
                    fetchedServices[index].providerName = try await fetchUserName(userId: userId)
                }
            }

            self.services = fetchedServices
            self.filteredServices = fetchedServices
        } catch {
            errorMessage = "Failed to load services. Please try again."
            print("Error fetching services: \(error.localizedDescription)")
        }
    }

    private func fetchUserName(userId: Int64) async throws -> String {
        return try await service.fetchUserName(userId: userId)
    }

    private func filterServices(query: String) {
        guard !query.isEmpty else {
            filteredServices = services
            return
        }
        filteredServices = services.filter {
            $0.serviceTitle.localizedCaseInsensitiveContains(query) ||
            ($0.providerName?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
}
