//
//  HomeViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import SwiftUI
import Foundation

// HomeViewModel: Manages categories and recommended services.

@MainActor
class HomeViewModel: ObservableObject {
    @Published var categories: [ServiceCategory] = []
    @Published var recommendedServices: [ServiceProfile] = []
    @Published var isLoading = false

    private let service: ServicesServiceProtocol

    init(service: ServicesServiceProtocol = ServicesService()) {
        self.service = service
        print("HomeViewModel initialized - checking if data is loaded.")
        // Only load data if categories are not already loaded
        if categories.isEmpty {
            Task {
                await loadData()
            }
        }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        // Only fetch if categories are not already loaded
        if categories.isEmpty {
            do {
                // Fetch categories and recommended services concurrently
                async let categoriesTask = service.fetchCategories()
                async let recommendedServicesTask = service.fetchRecommendedServices()

                // Await results for categories and services
                let (fetchedCategories, fetchedServices) = await (try categoriesTask, try recommendedServicesTask)

                categories = fetchedCategories
                recommendedServices = fetchedServices

                print("Data loaded successfully. Categories count: \(categories.count), Services count: \(recommendedServices.count)")

            } catch {
                print("Error loading data: \(error.localizedDescription)")
            }
        }
    }
}
