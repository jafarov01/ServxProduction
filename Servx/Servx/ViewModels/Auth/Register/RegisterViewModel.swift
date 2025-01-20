//
//  RegisterViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 11. 30..
//

import Combine
import Foundation

struct Profile: Identifiable {
    let id = UUID()
    var serviceCategory: String = ""
    var serviceAreas: [String] = [""]
    var education: String = ""
    var workExperience: String = ""
}

class RegisterViewModel: ObservableObject {
    // MARK: - Published Variables
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var address: String = ""
    @Published var country: String = ""
    @Published var city: String = ""
    @Published var isRememberMe: Bool = false
    
    // Profiles
    @Published var profiles: [Profile] = []
    
    // Dropdown options for Service Provider
    let educationOptions = ["High School", "Bachelor's Degree", "Master's Degree", "PhD"]
    let serviceCategoryOptions = ["Plumbing", "Electrical", "Cleaning", "Carpentry"]
    let serviceAreaOptions = ["Toilet Issue", "Kitchen Tube", "Wiring Repair", "Appliance Setup"]
    let workExperienceOptions = ["< 1 year", "1-3 years", "3-5 years", "> 5 years"]

    // Validation States
    @Published var isProfessionalDetailsStageValid: Bool = false
    
    // Validation Logic
    private func validateProfessionalDetails() {
        // At least one profile must be valid
        isProfessionalDetailsStageValid = profiles.allSatisfy { profile in
            !profile.serviceCategory.isEmpty &&
            !profile.serviceAreas[0].isEmpty && // Check at least one service area
            !profile.education.isEmpty &&
            !profile.workExperience.isEmpty
        }
    }
    
    // Add a Profile
    func addProfile() {
        let newProfile = Profile()
        profiles.append(newProfile)
    }
    
    // Remove a Profile
    func removeProfile(at index: Int) {
        profiles.remove(at: index)
        validateProfessionalDetails()
    }
    
    // Ensure at Least One Profile Exists
    func ensureAtLeastOneProfile() {
        if profiles.isEmpty {
            profiles.append(Profile())
        }
    }
}
