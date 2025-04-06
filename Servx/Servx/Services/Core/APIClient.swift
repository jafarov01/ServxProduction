//
//  ApiClient.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        print("===== APIClient.request() called =====")
        
        // Validating URL
        guard let url = URL(string: endpoint.url) else {
            print("Error: Invalid URL: \(endpoint.url)")
            throw NetworkError.invalidURL
        }
        
        print("Requesting URL: \(url) with method: \(endpoint.method.rawValue)")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Adding authorization if required
        if endpoint.requiresAuth {
            print("Adding authorization header to request")
            do {
                let token = try await getAuthToken()
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                print("Authorization header set with Bearer token: \(token)")
            } catch {
                print("Failed to fetch auth token: \(error.localizedDescription)")
                throw NetworkError.unauthorized
            }
        }
        
        // Adding body if the endpoint requires it
        if let body = endpoint.body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                urlRequest.httpBody = jsonData
                print("Request body set: \(String(data: jsonData, encoding: .utf8) ?? "No body data")")
            } catch {
                print("Failed to encode request body: \(error.localizedDescription)")
                throw NetworkError.unknown
            }
        }
        
        // Making network request
        do {
            print("Sending request to \(urlRequest.url?.absoluteString ?? "Unknown URL") with headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            
            let (data, response) = try await session.data(for: urlRequest)
            print("Response received for URL: \(urlRequest.url?.absoluteString ?? "Unknown URL")")
            
            // Checking if response is valid
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid response type received: \(response)")
                throw NetworkError.unknown
            }
            
            print("HTTP Status: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
            
            switch httpResponse.statusCode {
            case 200...299:
                print("Request successful. Status Code: \(httpResponse.statusCode)")
                
                // Decoding the response
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    print("Decoding successful. Returning decoded response: \(decodedResponse)")
                    return decodedResponse
                } catch {
                    print("Error: Decoding failed. Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                    print("Decoding error: \(error.localizedDescription)")
                    throw NetworkError.decodingError
                }
                
            case 401:
                print("Error: 401 Unauthorized - Invalid or expired token.")
                throw NetworkError.unauthorized
            case 403:
                print("Error: 403 Forbidden - User does not have permission.")
                throw NetworkError.forbidden
            case 404:
                print("Error: 404 Not Found - Resource does not exist.")
                throw NetworkError.notFound
            case 500...599:
                print("Error: Server error - Status Code: \(httpResponse.statusCode)")
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            default:
                print("Unknown error. HTTP status code: \(httpResponse.statusCode).")
                throw NetworkError.unknown
            }
        } catch {
            print("Error: Network request failed with error: \(error.localizedDescription).")
            throw NetworkError.unknown
        }
    }
    
    private func getAuthToken() async throws -> String {
        print("===== APIClient.getAuthToken() called =====")
        
        do {
            guard let token = try KeychainManager.getToken(service: "auth") else {
                print("Error: Token not found in keychain.")
                throw NetworkError.unauthorized
            }
            print("Auth token retrieved from keychain.")
            return token
        } catch {
            print("Error: Keychain access error: \(error.localizedDescription).")
            throw NetworkError.unauthorized
        }
    }
}
