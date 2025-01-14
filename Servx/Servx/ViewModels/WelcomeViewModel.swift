//
//  WelcomeViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import SwiftUI

class WelcomeViewModel: ObservableObject {
    @Published var selectedCountry: Country?
    @Published var mobileNumber: String = ""
    @Published var mobileNumberError: String?
    @Published var countries: [Country] = [
        Country(name: "Select", code: ""),
        Country(name: "Hungary", code: "+36"),
        Country(name: "United States", code: "+1"),
        Country(name: "United Kingdom", code: "+44"),
        Country(name: "Azerbaijan", code: "+994")
    ]
        
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        $mobileNumber
            .receive(on: RunLoop.main)
            .map { [weak self] in self?.validateMobileNumber($0) }
            .assign(to: \.mobileNumberError, on: self)
    }
    
    private func validateMobileNumber(_ number: String) -> String? {
        let cleanedNumber = number.trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = cleanedNumber.count >= 7 && cleanedNumber.count <= 15
        return isValid ? nil : "Invalid mobile number"
    }
    
    var isFormValid: Bool {
        return mobileNumberError == nil && !mobileNumber.isEmpty && selectedCountry != nil
    }
    
    func continueAction() {
        if isFormValid {
            print("Continue with registration")
        } else {
            print("Invalid mobile number")
        }
    }
}
