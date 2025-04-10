//
//  UserRequests.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

struct UpdateUserRequest: Encodable, APIRequest {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let address: AddressUpdateRequest
}

struct AddressUpdateRequest: Encodable, APIRequest {
    let addressLine: String
    let city: String
    let zipCode: String
    let country: String
}
