//
//  SubcategoriesViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import Foundation

@MainActor
class SubcategoriesViewModel: ObservableObject {
    @Published private(set) var subcategories: [ServiceArea] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let service: ServicesServiceProtocol
    let category: ServiceCategory

    init(category: ServiceCategory, service: ServicesServiceProtocol = ServicesService()) {
        self.category = category
        self.service = service
    }

    func loadSubcategories() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            subcategories = try await service.fetchSubcategories(categoryId: category.id)
        } catch {
            errorMessage = "Failed to load subcategories. Please try again."
        }
    }
}
