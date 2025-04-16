//
//  BecomeServiceProviderViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 12..
//

import Foundation
import Combine

/// ViewModel for the "Become a Service Provider" registration form.
@MainActor
final class BecomeServiceProviderViewModel: ObservableObject {
    // MARK: - Form Fields
    @Published var education = ""
    @Published var selectedCategoryId: Int64? = nil {
        didSet { handleCategorySelection() }
    }
    @Published var selectedSubcategoryIds = Set<Int64>()
    @Published var workExperience = ""
    @Published var price = ""
    
    // MARK: - State
    @Published private(set) var categories: [ServiceCategory] = []
    @Published private(set) var subcategories: [ServiceArea] = []
    @Published private(set) var isLoading = false
    @Published private(set) var formValid = false
    @Published var submissionError: Error?
    @Published private(set) var didCompleteRegistration = false
    
    // MARK: - Services
    private let servicesService: ServicesServiceProtocol
    private let userService: UserServiceProtocol
    
    init(
        servicesService: ServicesServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.servicesService = servicesService
        self.userService = userService
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest4(
            $education,
            $selectedCategoryId,
            $selectedSubcategoryIds,
            Publishers.CombineLatest($workExperience, $price)
        )
        .map { education, category, subcategories, details in
            let (experience, price) = details
            return education.count >= 10 &&
            category != nil &&
            !subcategories.isEmpty &&
            (10...500).contains(experience.count) // Changed from 50 to 10
            && Double(price) ?? 0 >= 0.01
        }
        .assign(to: &$formValid)
    }
}

// MARK: - Data Operations
extension BecomeServiceProviderViewModel {
    func loadCategories() {
        guard categories.isEmpty else { return }
        
        isLoading = true
        Task {
            categories = (try? await servicesService.fetchCategories()) ?? []
            isLoading = false
        }
    }
    
    private func handleCategorySelection() {
        guard let categoryId = selectedCategoryId else { return }
        
        isLoading = true
        Task {
            subcategories = (try? await servicesService.fetchSubcategories(categoryId: categoryId)) ?? []
            isLoading = false
        }
    }
    
    func submitRegistration() async {
        guard formValid else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. Upgrade user role - FIXED SYNTAX
            let userResponse = try await userService.upgradeToProvider(
                request: UpgradeToProviderRequestDTO(education: education)
            )
            
            await MainActor.run {
                AuthenticatedUser.shared.authenticate(with: userResponse)
            }
            
            // 2. Create service profiles
            try await servicesService.createBulkServiceProfiles(
                request: BulkServiceProfileRequest(
                    categoryId: selectedCategoryId!,
                    serviceAreaIds: Array(selectedSubcategoryIds),
                    workExperience: workExperience,
                    price: Double(price) ?? 0.0
                )
            )
            
            // 3. Update successful state
            await MainActor.run {
                didCompleteRegistration = true
                submissionError = nil
            }
            
        } catch let error as NetworkError {
            await MainActor.run {
                submissionError = error
                print("🔴 Network Error: \(error.localizedDescription)")
            }
        } catch {
            await MainActor.run {
                submissionError = error
                print("🔴 Unexpected Error: \(error.localizedDescription)")
            }
        }
    }
    
}
