//
//  RegisterResponse.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

struct RegisterResponse: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let languagesSpoken: [String]
    let address: AddressResponse
    let role: String

    struct AddressResponse: Decodable {
        let city: String
        let country: String
        let zipCode: String
        let addressLine: String
    }
}
