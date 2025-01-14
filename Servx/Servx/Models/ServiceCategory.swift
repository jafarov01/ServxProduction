//
//  ServiceCategory.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import Foundation

struct ServiceCategory : Hashable {
    let name: String
    var subcategories: [ServiceSubcategory]
}
