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
        guard let url = URL(string: endpoint.url) else {
            print("Error: Invalid URL: \(endpoint.url)")
            throw NetworkError.invalidURL
        }
        
        print("Requesting URL: \(url) with method: \(endpoint.method.rawValue)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        

        if endpoint.requiresAuth {
            let token = try await getAuthToken()
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            print("HTTP Status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return decodedResponse
                } catch {
                    print("Decoding failed: \(error.localizedDescription)")
                    throw NetworkError.decodingError
                }
            case 401:
                print("401 Unauthorized - Invalid or expired token.")
                throw NetworkError.unauthorized
            case 403:
                print("403 Forbidden - User does not have permission.")
                throw NetworkError.forbidden
            case 404:
                print("404 Not Found - Resource does not exist.")
                throw NetworkError.notFound
            case 500...599:
                print("Server error: \(httpResponse.statusCode)")
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw NetworkError.unknown
            }
        } catch {
            print("Network error: \(error.localizedDescription)")
            throw NetworkError.unknown
        }
    }
    
    private func getAuthToken() async throws -> String {
        do {
            guard let token = try KeychainManager.getToken(service: "auth") else {
                throw NetworkError.unauthorized
            }
            return token
        } catch {
            print("Keychain access error: \(error.localizedDescription)")
            throw NetworkError.unauthorized
        }
    }
}
