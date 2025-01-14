//
//  RegisterViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 11. 30..
//

import Combine
import Foundation

class RegisterViewModel: ObservableObject {
    // MARK: - Published Variables
    // Common inputs
    @Published var email: String = "" { didSet { validateForm() } }
    @Published var password: String = "" { didSet { validateInitialStage() } }
    @Published var firstName: String = "" { didSet { validateForm() } }
    @Published var lastName: String = "" { didSet { validateForm() } }
    @Published var phoneNumber: String = "" { didSet { validateForm() } }
    @Published var address: String = "" { didSet { validateForm() } }
    @Published var country: String = "" { didSet { validateForm() } }
    @Published var city: String = "" { didSet { validateForm() } }
    @Published var isRememberMe: Bool = false

    // Service Provider-specific inputs
    @Published var selectedEducation: String = "" { didSet { validateProfessionalDetails() } }
    @Published var selectedServiceArea: String = "" { didSet { validateProfessionalDetails() } }
    @Published var selectedLanguage: String = "" { didSet { validateProfessionalDetails() } }
    @Published var selectedWorkExperience: String = "" { didSet { validateProfessionalDetails() } }

    // Validation states for different stages
    @Published var isFormValid: Bool = false                // For Service Seeker full form validation
    @Published var isInitialStageValid: Bool = false        // For Service Provider Initial Stage
    @Published var isProfileDetailsStageValid: Bool = false // For Service Provider Profile Details
    @Published var isProfessionalDetailsStageValid: Bool = false // For Service Provider Professional Details

    // Dropdown options for Service Provider
    let educationOptions = ["High School", "Bachelor's Degree", "Master's Degree", "PhD"]
    let serviceAreaOptions = ["Plumbing", "Electrical", "Cleaning", "Carpentry"]
    let languageOptions = ["English", "Spanish", "French", "German"]
    let workExperienceOptions = ["< 1 year", "1-3 years", "3-5 years", "> 5 years"]

    // MARK: - Validation Logic

    private func validateForm() {
        let isFirstNameValid = !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isLastNameValid = !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isEmailValid = email.contains("@") && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isPhoneNumberValid = !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isAddressValid = !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isCountryValid = !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isCityValid = !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        isFormValid = isFirstNameValid && isLastNameValid && isEmailValid &&
                      isPhoneNumberValid && isAddressValid && isCountryValid && isCityValid
    }

    private func validateInitialStage() {
        let isEmailValid = email.contains("@") && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isPasswordValid = password.count >= 6

        isInitialStageValid = isEmailValid && isPasswordValid
    }

    private func validateProfessionalDetails() {
        let isEducationValid = !selectedEducation.isEmpty
        let isServiceAreaValid = !selectedServiceArea.isEmpty
        let isLanguageValid = !selectedLanguage.isEmpty
        let isWorkExperienceValid = !selectedWorkExperience.isEmpty

        isProfessionalDetailsStageValid = isEducationValid && isServiceAreaValid &&
                                          isLanguageValid && isWorkExperienceValid
    }

    // MARK: - Test Validation Function

    func testValidation() {
        firstName = "John"
        lastName = "Doe"
        email = "john.doe@example.com"
        phoneNumber = "1234567890"
        address = "123 Main St"
        country = "USA"
        city = "New York"
        print("Is form valid? \(isFormValid)") // Should print true if validation works.
    }

    // MARK: - Registration Methods
    func createProfile() {
        // Logic for Service Seeker registration
    }

    func completeRegistration() {
        // Logic for Service Provider registration
    }
}
