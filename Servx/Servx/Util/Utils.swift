//
//  PageWrapper.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 30..
//

import Foundation

struct PageWrapper<T: Codable>: Codable {
    let content: [T]
    let page: PageInfo

    var totalPages: Int { page.totalPages }
    var totalElements: Int64 { page.totalElements }
    var size: Int { page.size }
    var number: Int { page.number }
    var first: Bool { page.first ?? (page.number == 0) }
    var last: Bool { page.last ?? (page.number >= page.totalPages - 1 && page.totalPages > 0) }
    var numberOfElements: Int { page.numberOfElements ?? content.count }
    var empty: Bool { page.empty ?? content.isEmpty }

    struct PageInfo: Codable {
        let size: Int
        let number: Int
        let totalElements: Int64
        let totalPages: Int
        let first: Bool?
        let last: Bool?
        let numberOfElements: Int?
        let empty: Bool?
    }
}

extension String {
    func toDate() -> Date? {
        return DateFormatter.iso8601Full.date(from: self)
    }
}

extension Date {
    func toString() -> String {
        return DateFormatter.iso8601Full.string(from: self)
    }
}
