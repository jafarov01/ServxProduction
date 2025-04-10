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
    @Published var user: User?
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var streetAddress = ""
    @Published var city = ""
    @Published var zipCode = ""
    @Published var isLoading = false
    @Published var isValid = false
    
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
        setupValidation()
        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserDataUpdate),
            name: .userDataUpdated,
            object: nil
        )
    }

    @objc private func handleUserDataUpdate() {
        Task {
            await loadUser()
        }
    }
    
    func loadUser() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await userService.getUserDetails()
            let user = response.toEntity()
            
            await MainActor.run {
                updateFormFields(with: user)
                self.user = user
            }
        } catch {
            print("Error loading user: \(error.localizedDescription)")
        }
    }
    
    func saveChanges() async {
            guard isValid else { return }
            isLoading = true
            
            do {
                guard let user = user else {
                    throw ValidationError.invalidUserState
                }
                
                let request = UpdateUserRequest(
                    firstName: firstName,
                    lastName: lastName,
                    phoneNumber: phoneNumber,
                    address: AddressUpdateRequest(
                        addressLine: streetAddress,
                        city: city,
                        zipCode: zipCode,
                        country: user.address.country // Preserve existing country
                    )
                )
                
                let updatedResponse = try await userService.updateUserDetails(request)
                let updatedUser = updatedResponse.toEntity()
                
                await MainActor.run {
                    self.user = updatedUser
                    AuthenticatedUser.shared.updateUser(user: updatedUser)
                    NotificationCenter.default.post(name: .userDataUpdated, object: nil)
                }
                
            } catch {
                await MainActor.run {
                    // Handle error (e.g., show alert)
                    print("Save failed: \(error.localizedDescription)")
                }
            }
            
            isLoading = false
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
        .map { values in
            !values.0.isEmpty &&
            !values.1.isEmpty &&
            !values.2.isEmpty &&
            !values.3.isEmpty
        }
        .assign(to: &$isValid)
    }
}

enum ValidationError: Error {
    case invalidUserState
}
