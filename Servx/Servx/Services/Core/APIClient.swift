//
//  ApiClient.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

// MARK: - Consolidated APIClient
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func upload<T: Decodable>(
        endpoint: Endpoint,
        fileData: Data,
        fileName: String,
        mimeType: String
    ) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let urlRequest = try await createRequest(for: endpoint)
        return try await handleDataTask(with: urlRequest)
    }
    
    func upload<T: Decodable>(
        endpoint: Endpoint,
        fileData: Data,
        fileName: String,
        mimeType: String
    ) async throws -> T {
        var urlRequest = try await createRequest(for: endpoint)
        
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        return try await handleDataTask(with: urlRequest)
    }
    
    private func createRequest(for endpoint: Endpoint) async throws -> URLRequest {
        guard let url = URL(string: endpoint.url) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        
        if endpoint.requiresAuth {
            let token = try await getAuthToken()
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return urlRequest
    }
    
    private func handleDataTask<T: Decodable>(with urlRequest: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        try validateStatusCode(httpResponse.statusCode)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    private func validateStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case 200...299: return
        case 401: throw NetworkError.unauthorized
        case 403: throw NetworkError.forbidden
        case 404: throw NetworkError.notFound
        case 500...599: throw NetworkError.serverError(statusCode: statusCode)
        default: throw NetworkError.unknown
        }
    }
    
    private func getAuthToken() async throws -> String {
        guard let token = try KeychainManager.getToken(service: "auth") else {
            throw NetworkError.unauthorized
        }
        return token
    }
}
