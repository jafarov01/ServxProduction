//
//  SubcategoriesViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import Foundation

//SubcategoriesViewModel: Fetches subcategories based on selected category.
@MainActor
class SubcategoriesViewModel: ObservableObject {
    @Published var subcategories: [ServiceArea] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: ServicesServiceProtocol
    let category: ServiceCategory

    init(category: ServiceCategory, service: ServicesServiceProtocol = ServicesService()) {
        print("=====================================")
        print("SubcategoriesViewModel initialized for category: \(category.name), id: \(category.id)")
        self.category = category
        self.service = service
        print("=====================================")
    }

    func loadSubcategories() async {
        print("=====================================")
        print("Loading subcategories for category: \(category.name), id: \(category.id). Setting isLoading to true")
        isLoading = true
        errorMessage = nil
        defer {
            print("Loading complete for subcategories. Setting isLoading to false")
            isLoading = false
        }

        do {
            print("Fetching subcategories...")
            subcategories = try await service.fetchSubcategories(categoryId: category.id)
            print("Subcategories fetched successfully: \(subcategories.count) items")
        } catch {
            errorMessage = "Failed to load subcategories. Please try again."
            print("Error fetching subcategories for category \(category.name): \(error.localizedDescription)")
        }
        print("=====================================")
    }
}
