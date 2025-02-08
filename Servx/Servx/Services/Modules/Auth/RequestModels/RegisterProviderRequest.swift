//
//  RegisterProviderRequest.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// A model for the registration payload of a Service Provider.
struct RegisterProviderRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phoneNumber: String
    let role: String = "SERVICE_PROVIDER" // Enforced constant
    let address: AddressRequest
    var languagesSpoken: Set<String>
    let education: String
    var profiles: [ServiceProviderProfileRequest]
}

/// A nested model for the service provider's profile.
struct ServiceProviderProfileRequest: Encodable {
    var serviceCategoryId: Int64
    var serviceAreaIds: [Int64]
    var workExperience: String
}

/// Reuse the same `AddressRequest` structure as in `RegisterSeekerRequest`.
