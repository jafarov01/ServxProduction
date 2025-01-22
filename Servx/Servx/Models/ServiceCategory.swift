//
//  ServiceCategory.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import Foundation

struct ServiceCategory: Codable, Identifiable {
    let id: String
    let name: String
    var serviceAreas: [ServiceArea]
}
