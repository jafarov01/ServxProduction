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
        print("\n===== APIClient Request =====")
        print("📤 \(endpoint.method.rawValue) \(endpoint.url)")
        print("🔑 Requires Auth: \(endpoint.requiresAuth)")
        if let body = endpoint.body {
            let jsonData = try JSONEncoder().encode(body)
            print("📦 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")
        }
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
            print("🚨 APIClient Error: Invalid URL for endpoint - \(endpoint.url)")
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        
        if endpoint.requiresAuth {
            let token = try await getAuthToken()
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Auth Token: \(token.prefix(6))...")  // Partial token for security
        }
        
        if let body = endpoint.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        print("🧠 Request Headers:")
        urlRequest.allHTTPHeaderFields?.forEach { print("   \($0.key): \($0.value)") }
        
        return urlRequest
    }
    
    private func handleDataTask<T: Decodable>(with urlRequest: URLRequest) async throws -> T {
        print("\n===== APIClient Response =====")
        let (data, response) = try await session.data(for: urlRequest)
        
        // Response Metadata
        if let httpResponse = response as? HTTPURLResponse {
            print("ℹ️ Status Code: \(httpResponse.statusCode)")
            print("🔗 URL: \(httpResponse.url?.absoluteString ?? "N/A")")
        }
        
        // Response Body
        let jsonString = String(data: data, encoding: .utf8) ?? "Non-UTF8 Data"
        print("📥 Raw Response (\(data.count) bytes):")
        print(jsonString.prefix(1000))  // Limit to first 1000 chars
        
        // Validate Status Code
        guard let httpResponse = response as? HTTPURLResponse else {
            print("🚨 Invalid Response Format")
            throw NetworkError.invalidResponse
        }
        
        do {
            try validateStatusCode(httpResponse.statusCode)
        } catch {
            print("🚨 Status Code Error: \(error)")
            throw error
        }
        
        if data.isEmpty && T.self == EmptyResponseDTO.self {
            print("✅ Empty response handled successfully")
            return EmptyResponseDTO() as! T
        }
        
        // Decoding
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            print("✅ Successfully Decoded \(T.self)")
            return decoded
        } catch let DecodingError.typeMismatch(expectedType, context) {
            print("🚨 DECODING ERROR: Type mismatch")
            print("🔍 Expected Type: \(expectedType)")
            print("📜 Context: \(context.debugDescription)")
            print("🗺 Coding Path: \(context.codingPath)")
            throw NetworkError.decodingError
        } catch let error as DecodingError {
            print("🚨 DECODING ERROR: \(error.errorDescription ?? "Unknown decoding error")")
            throw NetworkError.decodingError
        } catch {
            print("🚨 UNEXPECTED ERROR: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func validateStatusCode(_ statusCode: Int) throws {
        print("🔍 Validating Status Code: \(statusCode)")
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

enum NetworkConstants {
    static let baseURL = "http://localhost:8080"
    static let uploadsPath = "/uploads/"
}
