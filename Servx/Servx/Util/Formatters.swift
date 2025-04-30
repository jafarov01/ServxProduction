//
//  Formatters.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 22..
//

import Foundation

extension DateFormatter {

    /// Formatter for ISO8601 date strings WITH fractional seconds from the backend.
    /// Timezone is UTC (secondsFromGMT: 0). Matches backend Instant/Timestamp format.
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        // Adjust format string precisely based on backend output if needed
        // "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" expects exactly 6 fractional digits
        // If backend sometimes sends fewer (e.g., .SSS), adjust or use ISO8601DateFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Assume backend sends UTC
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed formats
        return formatter
    }()

    /// Formatter specifically for creating "YYYY-MM-DD" strings for API query parameters.
    /// Uses UTC timezone to avoid potential off-by-one day errors depending on client/server timezone differences.
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Use UTC for date query parameters
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // You could also add your standard display formatters here if desired
    // static let mediumDateShortTime: DateFormatter = { ... }()
}

// Also, ensure your String/Date extensions use the correct formatter if needed elsewhere
extension String {
    /// Parses an ISO8601 string (with fractional seconds) into a Date using the standard app formatter.
    func toISODate() -> Date? {
        return DateFormatter.iso8601Full.date(from: self)
    }
}

extension Date {
     /// Formats a Date into an ISO8601 string (with fractional seconds) using the standard app formatter.
     /// Note: Usually not needed if sending Dates directly in Codable bodies, but useful if manually constructing strings.
    func toISOString() -> String {
        return DateFormatter.iso8601Full.string(from: self)
    }
    
    /// Formats a Date into "YYYY-MM-DD" string using the standard app formatter (useful for API query params).
    func toYYYYMMDDString() -> String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
}
