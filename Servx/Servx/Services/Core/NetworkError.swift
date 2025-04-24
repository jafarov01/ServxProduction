//
//  NetworkError.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case serverError(statusCode: Int)
    case decodingError
    case noData
    case unauthorized
    case forbidden
    case notFound
    case timeout
    case unknown
    case tokenRefreshFailed
    case invalidResponse
    case invalidURLFormat
    case invalidImageData
    case conflict
    case invalidRequest
    case duplicateReview
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestFailed: return "Request failed"
        case .serverError(let code): return "Server error (\(code))"
        case .decodingError: return "Failed to decode response"
        case .noData: return "No data received"
        case .unauthorized: return "Session expired"
        case .forbidden: return "Access forbidden"
        case .notFound: return "Resource not found"
        case .timeout: return "Request timed out"
        case .tokenRefreshFailed: return "Failed to refresh session"
        case .unknown: return "Unknown error occurred"
        case .invalidResponse: return "Invalid response"
        case .invalidURLFormat: return "Invalid URL format"
        case .invalidImageData: return "Invalid image data"
        case .conflict: return "Conflict occurred - Role is already assigned"
        case .invalidRequest: return "Invalid request"
        case .duplicateReview: return "You have already submitted a review for this booking."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .unauthorized, .tokenRefreshFailed:
            return "Please login again"
        case .forbidden:
            return "Check your permissions"
        case .timeout:
            return "Check your network connection"
        case .duplicateReview:
            return "You can only review a booking once."
        default:
            return "Please try again later"
        }
    }
}
