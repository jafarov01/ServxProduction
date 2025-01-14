//
//  NetworkError.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 03..
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server responded with an invalid response."
        case .decodingError:
            return "Failed to decode the response."
        case .unknownError(let error):
            return error.localizedDescription
        }
    }

    static func map(_ error: Error) -> NetworkError {
        return (error as? DecodingError) != nil ? .decodingError : .unknownError(error)
    }
}
