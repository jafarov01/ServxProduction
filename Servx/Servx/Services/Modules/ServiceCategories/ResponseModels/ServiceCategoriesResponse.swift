//
//  ServiceCategoriesResponse.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

struct ServiceCategoriesResponse: Decodable {
    let categories: [ServiceCategory]
}
