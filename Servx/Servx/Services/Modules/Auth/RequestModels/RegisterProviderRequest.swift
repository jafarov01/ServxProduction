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
    let role: String
    let address: AddressRequest
    let languagesSpoken: [String]
    let education: String
    let profiles: [ServiceProviderProfileRequest]
}

/// A nested model for the service provider's profile.
struct ServiceProviderProfileRequest: Encodable {
    let serviceCategoryId: Int
    let serviceAreaIds: [Int]
    let workExperience: String
}

/// Reuse the same `AddressRequest` structure as in `RegisterSeekerRequest`.
