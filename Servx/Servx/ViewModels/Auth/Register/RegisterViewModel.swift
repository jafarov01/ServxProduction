//
//  RegisterViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 11. 30..
//

import Combine
import Foundation

@MainActor
class RegisterViewModel: ObservableObject {
    // MARK: - Published Variables
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var addressLine: String = ""
    @Published var zipCode: String = ""
    @Published var selectedCountry: String = ""
    @Published var selectedCity: String = ""
    @Published var selectedLanguages: Set<String> = []
    @Published var education: String = ""
    @Published var isRememberMe: Bool = false

    // Profiles for Service Provider
    @Published var profiles: [ServiceProviderProfileRequest] = []

    // Dropdown options
    @Published var countryOptions: [String] = ["Azerbaijan", "Estonia", "Hungary"]
    @Published var cityDictionary: [String: [String]] = [
        "Azerbaijan": ["Baku", "Ganja", "Sumqayit"],
        "Estonia": ["Tallinn", "Tartu", "Narva"],
        "Hungary": ["Budapest", "Debrecen", "Szeged"]
    ]
    private let countryCodeMap: [String: String] = [
        "Azerbaijan": "AZE",
        "Estonia": "EST",
        "Hungary": "HUN"
    ]
    func cityOptions(for country: String) -> [String] {
        cityDictionary[country] ?? []
    }
    
    @Published var languageOptions: [String] = ["English", "Azerbaijani", "Estonian", "Russian", "Hungarian", "German", "Turkish"]
    @Published var educationOptions: [String] = ["High School", "Bachelor's Degree", "Master's Degree", "PhD"]
    @Published var workExperienceOptions: [String] = ["< 1 year", "1-3 years", "3-5 years", "> 5 years"]
    @Published var serviceCategoryOptions: [ServiceCategory] = []
    @Published var serviceAreaOptions: [ServiceArea] = []
    @Published var selectedCategoryId: Int? = nil

    // Validation States
    @Published var isInitialStageValid: Bool = false
    @Published var isPersonalDetailsStageValid: Bool = false
    @Published var isProfessionalDetailsStageValid: Bool = false
    @Published var isLoading: Bool = false

    // Dependencies
    private let authService: AuthServiceProtocol
    private let serviceCategoryService: ServiceCategoryServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(authService: AuthServiceProtocol, serviceCategoryService: ServiceCategoryServiceProtocol) {
        self.authService = authService
        self.serviceCategoryService = serviceCategoryService
        setupValidation()
    }

    // MARK: - Validation Logic
    private func setupValidation() {
        setupInitialStageValidation()
        setupPersonalDetailsValidation()
        setupProfessionalDetailsValidation()
    }

    private func setupInitialStageValidation() {
        Publishers.CombineLatest(
            $email.map { !$0.isEmpty && $0.contains("@") },
            $password.map { $0.count >= 6 }
        )
        .map { $0 && $1 }
        .receive(on: DispatchQueue.main)
        .assign(to: &$isInitialStageValid)
    }

    private func setupPersonalDetailsValidation() {
        Publishers.CombineLatest4(
            $firstName.map { !$0.isEmpty },
            $lastName.map { !$0.isEmpty },
            $phoneNumber.map { !$0.isEmpty && $0.count >= 10 },
            $education.map { !$0.isEmpty }
        )
        .map { $0 && $1 && $2 && $3 }
        .receive(on: DispatchQueue.main)
        .assign(to: &$isPersonalDetailsStageValid)
    }

    private func setupProfessionalDetailsValidation() {
        $profiles
            .map { profiles in
                profiles.allSatisfy { profile in
                    profile.serviceCategoryId > 0 &&
                    !profile.serviceAreaIds.isEmpty &&
                    !profile.workExperience.isEmpty
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isProfessionalDetailsStageValid)
    }

    // MARK: - Profile Management
    func addProfile() {
        profiles.append(ServiceProviderProfileRequest(serviceCategoryId: 0, serviceAreaIds: [], workExperience: ""))
    }

    func removeProfile(at index: Int) {
        profiles.remove(at: index)
    }

    func ensureAtLeastOneProfile() {
        if profiles.isEmpty {
            addProfile()
        }
    }
    
    // MARK: - Fetching Service Categories and Areas
    func fetchServiceData() {
        Task {
            do {
                // Log before fetching service categories
                print("Starting to fetch service categories...")

                // Attempt to fetch service categories
                serviceCategoryOptions = try await serviceCategoryService.fetchServiceCategories()
                
                // Log after categories are fetched
                print("Service Categories fetched: \(serviceCategoryOptions.count)") // Debugging output
                if serviceCategoryOptions.isEmpty {
                    print("Warning: No service categories found.")
                }

            } catch let error as NetworkError {
                print("Network error fetching service categories: \(error.localizedDescription)")
            } catch {
                print("Failed to fetch service data: \(error.localizedDescription)")
            }
        }
    }

    func fetchServiceAreas() {
        // Ensure service areas are fetched only when category is selected
        guard let selectedCategoryId = selectedCategoryId else {
            print("No category selected, skipping service area fetch.")
            return
        }
        
        // Log when starting to fetch service areas
        print("Starting to fetch service areas for category \(selectedCategoryId)...")
        
        Task {
            do {
                // Fetch service areas based on the selected category
                serviceAreaOptions = try await serviceCategoryService.fetchServiceAreas(forCategoryId: selectedCategoryId)
                
                // Log how many areas were fetched
                print("Service Areas fetched for category \(selectedCategoryId): \(serviceAreaOptions.count)") // Debugging output
                
                if serviceAreaOptions.isEmpty {
                    print("Warning: No service areas found for category \(selectedCategoryId).")
                }
                
            } catch let error as NetworkError {
                print("Network error fetching service areas for category \(selectedCategoryId): \(error.localizedDescription)")
            } catch {
                print("Failed to fetch service areas for category \(selectedCategoryId): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Update selected category
    func updateSelectedCategory(id: Int) {
        selectedCategoryId = id
        fetchServiceAreas()
    }

    // MARK: - Registration Actions
    func registerServiceSeeker(completion: @escaping (Bool) -> Void) {
        guard isInitialStageValid, isPersonalDetailsStageValid else { return }
        

        let seekerRequest = RegisterSeekerRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            address: AddressRequest(
                addressLine: addressLine,
                city: selectedCity,
                zipCode: zipCode,
                country: selectedCountry
            ),
            languagesSpoken: selectedLanguages
        )

        isLoading = true
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let _ = try await self.authService.registerServiceSeeker(seekerRequest: seekerRequest)
                self.isLoading = false
                completion(true)
            } catch {
                self.isLoading = false
                completion(false)
            }
        }
    }

    func registerServiceProvider(completion: @escaping (Bool) -> Void) {
        guard isInitialStageValid, isPersonalDetailsStageValid, isProfessionalDetailsStageValid else { return }

        let countryCode = countryCodeMap[selectedCountry] ?? ""
        
        let providerRequest = RegisterProviderRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            address: AddressRequest(
                addressLine: addressLine,
                city: selectedCity,
                zipCode: zipCode,
                country: countryCode // Send code instead of name
            ),
            languagesSpoken: selectedLanguages,
            education: education,
            profiles: profiles
        )

        isLoading = true
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let _ = try await self.authService.registerServiceProvider(providerRequest: providerRequest)
                self.isLoading = false
                completion(true)
            } catch {
                self.isLoading = false
                completion(false)
            }
        }
    }
}
