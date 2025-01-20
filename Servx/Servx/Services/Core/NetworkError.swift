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

    // User-friendly error descriptions
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid."
        case .requestFailed:
            return "The request could not be completed. Please try again."
        case .serverError(let statusCode):
            return "The server encountered an error. Status code: \(statusCode)."
        case .decodingError:
            return "Failed to decode the response from the server."
        case .noData:
            return "No data was received from the server."
        case .unauthorized:
            return "Unauthorized access. Please check your credentials."
        case .forbidden:
            return "Access to the resource is forbidden."
        case .notFound:
            return "The requested resource could not be found."
        case .timeout:
            return "The request timed out. Please check your connection and try again."
        case .unknown:
            return "An unknown error occurred. Please try again later."
        }
    }

    // Status code mapping (if needed for conditional checks in APIClient)
    var statusCode: Int? {
        switch self {
        case .serverError(let statusCode):
            return statusCode
        default:
            return nil
        }
    }
}
