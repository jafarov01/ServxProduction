//
//  BecomeServiceProviderViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 12..
//

import SwiftUI

@MainActor
class BecomeServiceProviderViewModel: ObservableObject {
    @Published var education = ""
    @Published var categories: [ServiceCategory] = []
    @Published var selectedCategoryId: Int64? = nil {
        didSet {
            handleCategorySelection()
        }
    }
    @Published var subcategories: [ServiceArea] = []
    @Published var selectedSubcategoryIds = Set<Int64>()
    @Published var workExperience = ""
    @Published var price = ""
    
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoadingCategories = false
    @Published var isLoadingSubcategories = false
    @Published var isSubmitting = false
    
    private let servicesService: ServicesServiceProtocol
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(
        servicesService: ServicesServiceProtocol,
    ) {
        self.servicesService = servicesService
        self.selectedCategoryId = nil
    }
    
    // MARK: - Validation Properties
    var educationValid: Bool { education.count >= 10 }
    var educationError: String { education.isEmpty ? "Education required" : "Minimum 10 characters" }
    
    var categoryValid: Bool { selectedCategoryId != nil }
    var subcategoriesValid: Bool { !selectedSubcategoryIds.isEmpty }
    
    var workExperienceValid: Bool { (50...500).contains(workExperience.count) }
    var workExperienceError: String { workExperience.isEmpty ? "Experience required" : "50-500 characters required" }
    
    var priceValid: Bool {
        guard !price.isEmpty else { return false }
        guard let value = Double(price), value >= 0.01 else { return false }
        return price.filter { $0 == "." }.count <= 1
    }
    
    var priceError: String { price.isEmpty ? "Price required" : "Minimum $0.01 required" }
    
    var formValid: Bool {
        educationValid && categoryValid && subcategoriesValid && workExperienceValid && priceValid
    }
    
    // MARK: - Data Loading
    func loadCategories() {
        guard categories.isEmpty else { return }
        
        isLoadingCategories = true
        Task {
            do {
                categories = try await servicesService.fetchCategories()
            } catch {
                handleError(error)
            }
            isLoadingCategories = false
        }
    }
    
    func handleCategorySelection() {
        guard let categoryId = selectedCategoryId else { return }
        
        isLoadingSubcategories = true
        selectedSubcategoryIds.removeAll()
        
        print("🔄 Fetching subcategories for category ID: \(categoryId)")
        
        Task {
            do {
                subcategories = try await servicesService.fetchSubcategories(categoryId: categoryId)
                print("✅ Subcategories fetched: \(subcategories.count) items")
            } catch {
                print("❌ Subcategory fetch error: \(error)")
                handleError(error)
            }
            isLoadingSubcategories = false
        }
    }
    
    // MARK: - Form Submission
    func submitRegistration() async {
        guard validateSubmission() else { return }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            // 1. Upgrade user role
            try await UserService().upgradeToProvider(
                request: UpgradeToProviderRequestDTO(education: education)
            )
            
            // 2. Create service profiles
            try await servicesService.createBulkServiceProfiles(
                request: BulkServiceProfileRequest(
                    categoryId: selectedCategoryId!,
                    serviceAreaIds: Array(selectedSubcategoryIds),
                    workExperience: workExperience,
                    price: Double(price) ?? 0.0
                )
            )
            
            // 4. Navigate to manage services
            DispatchQueue.main.async {
                self.navigationManager.navigateTo(.manageServices)
            }
            
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        switch error {
        case let networkError as NetworkError:
            switch networkError {
            case .serverError(let code) where code == 409:
                errorMessage = "You're already a registered provider"
            case .unauthorized:
                errorMessage = "Session expired. Please login again."
            default:
                errorMessage = networkError.localizedDescription
            }
        default:
            errorMessage = error.localizedDescription
        }
        showError = true
    }
    
    private func validateSubmission() -> Bool {
        guard formValid else {
            errorMessage = "Please complete all required fields"
            showError = true
            return false
        }
        return true
    }
    
    func validatePriceFormat() {
        // Remove multiple decimal points
        let components = price.components(separatedBy: ".")
        if components.count > 2 {
            price = components[0] + "." + components[1...].joined()
        }
        
        // Limit to 2 decimal places
        if let dotIndex = price.firstIndex(of: ".") {
            let decimalPart = price[dotIndex...]
            if decimalPart.count > 3 { // including dot
                price = String(price.prefix(dotIndex.utf16Offset(in: price) + 3))
            }
        }
        
        // Handle leading decimal
        if price.starts(with: ".") {
            price = "0" + price
        }
    }
}
