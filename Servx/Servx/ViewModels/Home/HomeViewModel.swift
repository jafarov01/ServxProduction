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
        
        print("AuthenticatedUser set check", AuthenticatedUser.shared.isAuthenticated, " ", AuthenticatedUser.shared.id as Any, " ", AuthenticatedUser.shared.id as Any, " ", AuthenticatedUser.shared.email as Any)
        self.service = service
    }
    
    // Data loading function
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch categories and recommended services concurrently
            async let categoriesTask = service.fetchCategories()
            async let recommendedServicesTask = service.fetchRecommendedServices()
            
            // Await results for categories and services
            let (fetchedCategories, fetchedServices) = await (try categoriesTask, try recommendedServicesTask)
            
            // Assign fetched data to published properties
            categories = fetchedCategories
            recommendedServices = fetchedServices
        } catch {
            print("Error loading data: \(error.localizedDescription)")
        }
    }
}
