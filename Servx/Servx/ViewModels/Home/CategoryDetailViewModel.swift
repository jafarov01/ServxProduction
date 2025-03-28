//
//  CategoryDetailViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

import SwiftUI
import Foundation

@MainActor
class CategoryDetailViewModel: ObservableObject {
    @Published var serviceAreas: [ServiceArea] = []
    @Published var isLoading = false
    
    private let category: ServiceCategory
    private let service: ServiceCategoryServiceProtocol
    
    init(category: ServiceCategory, service: ServiceCategoryServiceProtocol = ServiceCategoryService()) {
        self.category = category
        self.service = service
    }
    
    func fetchServiceAreas() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            serviceAreas = try await service.fetchServiceAreas(forCategoryId: Int(category.id))
        } catch {
            // Handle error
        }
    }
}
