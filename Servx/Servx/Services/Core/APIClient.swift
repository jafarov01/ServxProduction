//
//  ApiClient.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

// Define a protocol for dependency injection and testability
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // Generic request method to handle all API calls
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = URL(string: endpoint.url) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue

        // Set headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaultsManager.authToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body for POST/PUT requests
        if let body = endpoint.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            // Check for HTTP response errors
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }

            switch httpResponse.statusCode {
            case 200...299:
                // Decode the response data
                return try JSONDecoder().decode(T.self, from: data)
            case 401:
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 404:
                throw NetworkError.notFound
            case 500...599:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw NetworkError.unknown
            }

        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed
        }
    }
}
