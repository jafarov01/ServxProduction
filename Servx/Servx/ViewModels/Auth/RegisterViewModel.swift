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
    @Published var selectedLanguages: [String] = []
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
        guard let countryCode = countryCodeMap[selectedCountry] else {
            print("Invalid country selection")
            completion(false)
            return
        }
        
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
            languagesSpoken: languageCodes
        )
        
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
    
    // MARK: - Validation Logic
    var isValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        isValidEmail &&
        isValidPassword &&
        isValidPhoneNumber &&
        !addressLine.isEmpty &&
        !zipCode.isEmpty &&
        !selectedCountry.isEmpty &&
        !selectedCity.isEmpty &&
        !selectedLanguages.isEmpty
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    var isValidPassword: Bool {
        password.count >= 8
    }
    
    var isValidPhoneNumber: Bool {
        let phoneRegEx = "^\\+[0-9]{10,15}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegEx).evaluate(with: phoneNumber)
    }
    
    func printValidationStatus() {
        print("""
        Validation Status:
        - First Name: \(!firstName.isEmpty)
        - Last Name: \(!lastName.isEmpty)
        - Email: \(isValidEmail)
        - Password: \(isValidPassword)
        - Phone: \(isValidPhoneNumber)
        - Address: \(!addressLine.isEmpty)
        - Zip: \(!zipCode.isEmpty)
        - Country: \(!selectedCountry.isEmpty)
        - City: \(!selectedCity.isEmpty)
        - Languages: \(!selectedLanguages.isEmpty)
        """)
    }
}
