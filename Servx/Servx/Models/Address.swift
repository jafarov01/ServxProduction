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

extension Address {
    var formattedAddress: String {
        "\(addressLine), \(city), \(zipCode), \(country)"
    }
    
    static func defaultAddress() -> Address {
        Address(
            addressLine: "Not specified",
            city: "Unknown",
            zipCode: "00000",
            country: "Unknown"
        )
    }
}
