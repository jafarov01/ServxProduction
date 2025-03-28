//
//  sik.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

import SwiftUI
import Foundation

struct ServiceAreaDetailView: View {
    let serviceArea: ServiceArea
    @StateObject private var viewModel: ServiceAreaViewModel
    
    init(serviceArea: ServiceArea) {
        self.serviceArea = serviceArea
        self._viewModel = StateObject(
            wrappedValue: ServiceAreaViewModel(serviceArea: serviceArea)
        )
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.services) { service in
                    ServiceCard(service: service)
                }
            }
            .padding()
        }
        .navigationTitle(serviceArea.name)
        .searchable(text: $viewModel.searchQuery)
        .task { await viewModel.fetchServices() }
    }
}

@MainActor
class ServiceAreaViewModel: ObservableObject {
    @Published var services: [ServiceProfile] = []
    @Published var searchQuery = ""
    @Published var isLoading = false
    
    private let serviceArea: ServiceArea
    private let service: ServiceAreaServiceProtocol
    
    init(serviceArea: ServiceArea, service: ServiceAreaServiceProtocol = ServiceAreaService()) {
        self.serviceArea = serviceArea
        self.service = service
    }
    
    func fetchServices() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            services = try await service.fetchServices(for: serviceArea.id)
        } catch {
            // Handle error
        }
    }
}
