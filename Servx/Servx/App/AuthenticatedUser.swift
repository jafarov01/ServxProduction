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
    
    func authenticateUser(from response: UserDetailsResponse) {
        self.id = response.id
        self.email = response.email
        self.role = response.role
        self.profilePhotoUrl = response.profilePhotoUrl
        self.firstName = response.firstName
        self.lastName = response.lastName
        self.phoneNumber = response.phoneNumber
        self.languagesSpoken = response.languagesSpoken
        self.isAuthenticated = true
        self.isOnboardingRequired = false

        self.address = mapToAddress(response.address)
    }
    
    // Method to map UserDetailsResponse.Address to Address entity
    private func mapToAddress(_ userDetailsAddress: UserDetailsResponse.Address) -> Address {
        return Address(
            addressLine: userDetailsAddress.addressLine,
            city: userDetailsAddress.city,
            zipCode: userDetailsAddress.zipCode,
            country: userDetailsAddress.country
        )
    }

    func logout() {
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
    }

    func completeOnboarding() {
        self.isOnboardingRequired = false
    }
}
