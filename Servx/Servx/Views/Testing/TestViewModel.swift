//
//  TestViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}

@MainActor
final class TestViewModel: ObservableObject {
    @Published var serviceCategories: [ServiceCategory] = []
    @Published var serviceAreas: [ServiceArea] = []
    @Published var errorMessage: IdentifiableError?

    private let serviceCategoryService: ServiceCategoryServiceProtocol

    init(serviceCategoryService: ServiceCategoryServiceProtocol = ServiceCategoryService()) {
        self.serviceCategoryService = serviceCategoryService
    }

    /// Fetch service categories
    func fetchCategories() async {
        do {
            serviceCategories = try await serviceCategoryService.fetchServiceCategories()
        } catch {
            handle(error)
        }
    }

    /// Fetch service areas
    func fetchAreas() async {
        do {
            serviceAreas = try await serviceCategoryService.fetchServiceAreas()
        } catch {
            handle(error)
        }
    }

    /// Handle errors
    private func handle(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = IdentifiableError(message: networkError.localizedDescription)
        } else {
            errorMessage = IdentifiableError(message: "An unexpected error occurred: \(error.localizedDescription)")
        }
    }
    
    func triggerError() {
            // Simulate an error
            self.errorMessage = IdentifiableError(message: "Something went wrong.")
        }
}
