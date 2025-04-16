//
//  ServiceCategory.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import Foundation

struct ServiceCategory: Codable, Identifiable, Hashable, SelectableOption {
    let id: Int64
    let name: String
}
