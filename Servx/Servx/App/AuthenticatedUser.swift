//
//  AuthenticatedUser.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

final class AuthenticatedUser {
    static let shared = AuthenticatedUser()

    // User data properties
    private(set) var id: Int64?
    private(set) var email: String?
    private(set) var role: String?
    private(set) var profilePhotoUrl: String?
    private(set) var firstName: String?
    private(set) var lastName: String?
    private(set) var phoneNumber: String?
    private(set) var address: Address?
    private(set) var languagesSpoken: [String]?

    // Onboarding and authentication status
    private(set) var isAuthenticated: Bool = false
    private(set) var isOnboardingRequired: Bool = true

    private init() {}

    // Computed property for convenience
    var fullName: String {
        "\(firstName ?? "") \(lastName ?? "")"
    }
    
    func authenticateUser(from response: UserResponse) {
        print("===== authenticateUser called =====")
        print("Received user details response: \(response)")
        
        self.id = response.id
        self.email = response.email
        self.role = response.role.rawValue
        self.profilePhotoUrl = response.profilePhotoUrl
        self.firstName = response.firstName
        self.lastName = response.lastName
        self.phoneNumber = response.phoneNumber
        self.languagesSpoken = response.languagesSpoken
        self.isAuthenticated = true
        self.isOnboardingRequired = false

        self.address = mapToAddress(response.address)
        
        print("User authenticated successfully. User details set:")
        print("ID: \(self.id ?? -1), Email: \(self.email ?? "N/A"), Full Name: \(self.fullName)")
    }
    
    // Method to map UserDetailsResponse.Address to Address entity
    private func mapToAddress(_ userDetailsAddress: AddressResponse) -> Address {
        print("===== mapToAddress called =====")
        print("Mapping address: \(userDetailsAddress)")
        
        return Address(
            addressLine: userDetailsAddress.addressLine,
            city: userDetailsAddress.city,
            zipCode: userDetailsAddress.zipCode,
            country: userDetailsAddress.country
        )
    }

    // Logout function - Reset all fields
    func logout() {
        print("===== logout called =====")
        
        self.id = nil
        self.email = nil
        self.role = nil
        self.profilePhotoUrl = nil
        self.firstName = nil
        self.lastName = nil
        self.phoneNumber = nil
        self.address = nil
        self.languagesSpoken = nil
        self.isAuthenticated = false
        self.isOnboardingRequired = true

        print("User logged out. All user data reset.")
    }

    // Complete onboarding
    func completeOnboarding() {
        print("===== completeOnboarding called =====")
        
        self.isOnboardingRequired = false
        print("Onboarding completed. isOnboardingRequired set to \(self.isOnboardingRequired)")
    }

    // MARK: - Update Methods

    // Update Profile Photo
    func updateProfilePhoto(url: String?) {
        self.profilePhotoUrl = url
        print("Profile photo updated to: \(url ?? "nil")")
    }

    // Update first name
    func updateFirstName(firstName: String) {
        self.firstName = firstName
        print("First name updated to: \(firstName)")
    }

    // Update last name
    func updateLastName(lastName: String) {
        self.lastName = lastName
        print("Last name updated to: \(lastName)")
    }

    // Update email
    func updateEmail(email: String) {
        self.email = email
        print("Email updated to: \(email)")
    }

    // Update phone number
    func updatePhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        print("Phone number updated to: \(phoneNumber)")
    }

    // Update address
    func updateAddress(address: Address) {
        self.address = address
        print("Address updated to: \(address)")
    }

    // Update languages spoken
    func updateLanguagesSpoken(languages: [String]) {
        self.languagesSpoken = languages
        print("Languages spoken updated to: \(languages)")
    }
}
