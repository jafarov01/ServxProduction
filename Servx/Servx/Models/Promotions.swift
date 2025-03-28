//
//  Promotions.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

struct Promotion: Codable, Identifiable {
    let id: String
    let title: String
    let imageUrl: String
    let targetCategoryId: Int64?
    let expirationDate: Date
}
