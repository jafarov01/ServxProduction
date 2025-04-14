//
//  ProfileEditViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI
import Combine

@MainActor
class ProfileEditViewModel: ObservableObject {
    @Published private(set) var user: User?

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var streetAddress = ""
    @Published var city = ""
    @Published var zipCode = ""
    @Published private(set) var isLoading = false
    @Published private(set) var isValid = false
    @Published var didComplete = false

    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
        setupObservers()
        setupValidation()
        setupInitialUser()
    }

    private func setupObservers() {
        // 🟢 Live updates from global user state
        AuthenticatedUser.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
                if let user = user {
                    self?.updateFormFields(with: user)
                }
            }
            .store(in: &cancellables)
    }

    private func setupInitialUser() {
        if let user = AuthenticatedUser.shared.currentUser {
            self.user = user
            updateFormFields(with: user)
        }
    }

    func saveChanges() async {
        guard isValid, let currentUser = AuthenticatedUser.shared.currentUser else { return }
        isLoading = true

        do {
            let request = UpdateUserRequest(
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                address: AddressUpdateRequest(
                    addressLine: streetAddress,
                    city: city,
                    zipCode: zipCode,
                    country: currentUser.address.country
                )
            )

            let updatedResponse = try await userService.updateUserDetails(request)
            await updateAuthenticatedUser(with: updatedResponse)

        } catch {
            print("Save failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    private func updateAuthenticatedUser(with response: UserResponse) async {
        let updatedUser = response.toEntity()
        AuthenticatedUser.shared.authenticate(with: response)
        await MainActor.run {
            self.user = updatedUser
            updateFormFields(with: updatedUser)
            didComplete = true
        }
    }

    private func updateFormFields(with user: User) {
        firstName = user.firstName
        lastName = user.lastName
        phoneNumber = user.phoneNumber
        streetAddress = user.address.addressLine
        city = user.address.city
        zipCode = user.address.zipCode
    }

    private func setupValidation() {
        Publishers.CombineLatest4(
            $firstName,
            $lastName,
            $streetAddress,
            $city
        )
        .map { !$0.isEmpty && !$1.isEmpty && !$2.isEmpty && !$3.isEmpty }
        .assign(to: &$isValid)
    }

    // 🟢 New helper
    var profilePhotoURL: URL? {
        user?.profilePhotoUrl
    }
}
