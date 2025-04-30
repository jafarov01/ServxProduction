//
//  ReviewDTO.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 23..
//

import Foundation

struct ReviewDTO: Codable, Identifiable, Hashable {
    let id: Int64
    let rating: Double
    let comment: String?
    let createdAt: String
    let reviewerName: String
    let reviewerFirstName: String?
    let reviewerLastName: String?
    let reviewerProfilePhotoUrl: String?

    var createdAtDate: Date? {
        DateFormatter.iso8601Full.date(from: createdAt)
    }

    var reviewerPhotoURLObject: URL? {
        URL(string: reviewerProfilePhotoUrl ?? "")
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ReviewDTO, rhs: ReviewDTO) -> Bool {
        lhs.id == rhs.id
    }
}

struct ReviewRequestDTO: Encodable, APIRequest {
    let bookingId: Int64
    let rating: Double
    let comment: String?
}
