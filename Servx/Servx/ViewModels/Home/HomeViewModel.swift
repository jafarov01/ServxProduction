//
//  HomeViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import SwiftUI
import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var categories: [ServiceCategory] = []
    @Published private(set) var recommendedServices: [ServiceProfile] = []
    @Published private(set) var isLoading = false

    
    private let service: ServicesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var shouldLoadData: Bool {
        categories.isEmpty || recommendedServices.isEmpty
    }
    init(service: ServicesServiceProtocol = ServicesService()) {
        self.service = service
    }
    
    func loadData() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let categories = service.fetchCategories()
            async let services = service.fetchRecommendedServices()
            
            let (loadedCategories, loadedServices) = await (try categories, try services)
            
            await MainActor.run {
                self.categories = loadedCategories
                self.recommendedServices = loadedServices
            }
        } catch {
            print("Error loading home data: \(error.localizedDescription)")
        }
    }
}
