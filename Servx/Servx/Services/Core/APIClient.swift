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
        // Log the endpoint URL and method
        guard let url = URL(string: endpoint.url) else {
            print("Error: Invalid URL: \(endpoint.url)")
            throw NetworkError.invalidURL
        }
        print("Requesting URL: \(url) with method: \(endpoint.method.rawValue)")
        
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
            // Log the start of the request
            let (data, response) = try await session.data(for: urlRequest)

            // Check for HTTP response errors
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid response received.")
                throw NetworkError.unknown
            }
            
            // Log HTTP status code and content type
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                print("Response Content-Type: \(contentType)")
            }

            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Successfully received a valid response, decode the data
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    return decodedData
                } catch let decodingError {
                    print("Decoding error: \(decodingError.localizedDescription)")
                    throw NetworkError.requestFailed
                }
            case 401:
                print("Unauthorized access (401).")
                throw NetworkError.unauthorized
            case 403:
                print("Forbidden access (403).")
                throw NetworkError.forbidden
            case 404:
                print("Not found (404).")
                throw NetworkError.notFound
            case 500...599:
                print("Server error: \(httpResponse.statusCode).")
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            default:
                print("Unexpected HTTP status code: \(httpResponse.statusCode).")
                throw NetworkError.unknown
            }

        } catch let error as NetworkError {
            // Catch specific network errors and log them
            print("NetworkError: \(error.localizedDescription)")
            throw error
        } catch {
            // Catch generic errors and log them
            print("Request failed with error: \(error.localizedDescription)")
            throw NetworkError.requestFailed
        }
    }
}
