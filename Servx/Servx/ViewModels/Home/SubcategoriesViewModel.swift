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
    @Published var subcategories: [Subcategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: ServicesServiceProtocol
    let category: ServiceCategory

    init(category: ServiceCategory, service: ServicesServiceProtocol = ServicesService()) {
        self.category = category
        self.service = service
    }

    func loadSubcategories() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            subcategories = try await service.fetchSubcategories(categoryId: category.id)
        } catch {
            errorMessage = "Failed to load subcategories. Please try again."
            print("Error fetching subcategories: \(error.localizedDescription)")
        }
    }
}
