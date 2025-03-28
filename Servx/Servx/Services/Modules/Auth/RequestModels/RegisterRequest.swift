//
//  RegisterSeekerRequest.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

struct RegisterRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phoneNumber: String
    let role: String // Remove default; send explicitly from frontend
    let address: AddressRequest
    let languagesSpoken: [String] // Change from Set to Array
}

struct AddressRequest: Encodable {
    let city: String
    let country: String
    let zipCode: String
    let addressLine: String
}
