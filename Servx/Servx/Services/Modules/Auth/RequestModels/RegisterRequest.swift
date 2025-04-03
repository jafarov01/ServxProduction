//
//  RegisterSeekerRequest.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

struct RegisterRequest: APIRequest {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phoneNumber: String
    let role: String
    let address: AddressRequest
    let languagesSpoken: [String]
}

struct AddressRequest: APIRequest {
    let city: String
    let country: String
    let zipCode: String
    let addressLine: String
}
