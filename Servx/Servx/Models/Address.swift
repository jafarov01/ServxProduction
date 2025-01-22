//
//  Address.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct Address: Codable {
    let addressLine: String
    let city: String
    let zipCode: String
    let country: String
}
