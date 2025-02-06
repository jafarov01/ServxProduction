//
//  ServiceSubCategory.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import Foundation

struct ServiceArea: Codable, Identifiable {
    let id: Int64
    let name: String
    let categoryId: Int64
    let categoryName: String
}
