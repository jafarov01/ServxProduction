//
//  ServiceAreaViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

import SwiftUI
import Foundation

@MainActor
class ServiceAreaViewModel: ObservableObject {
    @Published var serviceProfiles: [ServiceProfile] = []
    @Published var isLoading = false
    
    private let serviceArea: ServiceArea
    private let service: ServiceAreaServiceProtocol
    
    init(serviceArea: ServiceArea, service: ServiceAreaServiceProtocol = ServiceAreaService()) {
        self.serviceArea = serviceArea
        self.service = service
    }
    
    func fetchServiceProfiles() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            serviceProfiles = try await service.fetchServiceProfiles(for: serviceArea.id)
        } catch {
            // Handle error
        }
    }
}
