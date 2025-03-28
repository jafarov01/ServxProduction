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
    @Published var selectedLanguages: [String] = [] // Changed to Array (was Set)
    @Published var education: String = ""
    @Published var isRememberMe: Bool = false
    var isLoading = false

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
    private let languageCodeMap: [String: String] = [
        "English": "en",
        "Azerbaijani": "az",
        "Estonian": "et",
        "Russian": "ru",
        "Hungarian": "hu",
        "German": "de",
        "Turkish": "tr"
    ]

    // Dependencies
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Registration Actions
    func register(completion: @escaping (Bool) -> Void) {
        // Convert selected country name to code
        guard let countryCode = countryCodeMap[selectedCountry] else {
            print("Invalid country selection")
            completion(false)
            return
        }
        
        // Convert selected language names to codes
        let languageCodes = selectedLanguages.compactMap { languageCodeMap[$0] }
        
        let request = RegisterRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            role: "SERVICE_SEEKER",
            address: AddressRequest(
                city: selectedCity,
                country: countryCode,
                zipCode: zipCode,
                addressLine: addressLine
            ),
            languagesSpoken: languageCodes // Send codes instead of full names
        )

        // Debug print the request
        print("Sending country code:", countryCode)
        print("Sending language codes:", languageCodes)
        
        isLoading = true
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let _ = try await self.authService.register(request: request)
                self.isLoading = false
                completion(true)
            } catch {
                print("Registration error: \(error)")
                self.isLoading = false
                completion(false)
            }
        }
    }
}

// MARK: - Validation Logic
extension RegisterViewModel {
    var isValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        isValidEmail(email) &&
        isValidPhoneNumber(phoneNumber) &&
        !addressLine.isEmpty &&
        !zipCode.isEmpty &&
        !selectedCountry.isEmpty &&
        !selectedCity.isEmpty &&
        !selectedLanguages.isEmpty // Now checks array count
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        // Match Spring Boot's @Pattern(regexp = "^\\+[0-9]{10,15}$")
        let phoneRegEx = "^\\+[0-9]{10,15}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
}
