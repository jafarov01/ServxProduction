//
//  RegisterSeekerRequest.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// A model for the registration payload of a Service Seeker.
struct RegisterSeekerRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phoneNumber: String
    let role: String
    let address: AddressRequest
    let languagesSpoken: [String]
}

/// A nested model for the address in registration.
struct AddressRequest: Encodable {
    let addressLine: String
    let city: String
    let zipCode: String
    let country: String
}
