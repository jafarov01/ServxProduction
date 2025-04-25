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
        print("📤 Sending request to \(endpoint.url) with method \(endpoint.method.rawValue)")
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
        guard var urlComponents = URLComponents(string: endpoint.url) else {
            print("🚨 Invalid base URL string - \(endpoint.url)")
            throw NetworkError.invalidURL
        }

        if let parameters = endpoint.parameters, !parameters.isEmpty {
            var queryItems = urlComponents.queryItems ?? []
            queryItems.append(contentsOf: parameters)
            urlComponents.queryItems = queryItems
            print("📝 Added query parameters: \(parameters.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&"))")
        }

        guard let finalUrl = urlComponents.url else {
            print("🚨 Could not construct final URL from components for \(endpoint.url)")
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: finalUrl)
        urlRequest.httpMethod = endpoint.method.rawValue

        if endpoint.requiresAuth {
            let token = try await getAuthToken()
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Auth Token: \(token.prefix(6))...")
        }

        if endpoint.method != .get {
            if let requestBody = endpoint.body {
                do {
                    let bodyData = try JSONEncoder().encode(requestBody)
                    urlRequest.httpBody = bodyData
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    print("📦 Encoded Body: \(String(data: bodyData, encoding: .utf8)?.prefix(500) ?? "Non-UTF8 Data")")
                } catch {
                    print("🚨 Failed to encode request body: \(error)")
                    throw NetworkError.encodingError
                }
            }

        } else if endpoint.body != nil {
            print("⚠️ Warning: Body provided for GET request, ignoring.")
        }

        print("🧠 Request Headers: \(urlRequest.allHTTPHeaderFields?.map { "\($0.key): \($0.value)" }.joined(separator: ", ") ?? "None")")

        return urlRequest
    }
    
    private func handleDataTask<T: Decodable>(with urlRequest: URLRequest) async throws -> T {
        print("\n===== APIClient Response =====")
        let (data, response) = try await session.data(for: urlRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("ℹ️ Status Code: \(httpResponse.statusCode)")
            print("🔗 URL: \(httpResponse.url?.absoluteString ?? "N/A")")
        }
        
        let jsonString = String(data: data, encoding: .utf8) ?? "Non-UTF8 Data"
        print("📥 Response Data (\(data.count) bytes): \(jsonString.prefix(1000))")
        
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
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            let decoded = try decoder.decode(T.self, from: data)
            print("✅ Successfully Decoded \(T.self)")
            return decoded
        } catch let error as DecodingError {
            print("\n🚨 Decoding Error:")
            switch error {
            case .typeMismatch(let type, let context):
                print("TYPE MISMATCH: Expected \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                
            case .valueNotFound(let type, let context):
                print("VALUE NOT FOUND: Expected \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                
            case .keyNotFound(let key, let context):
                print("KEY NOT FOUND: Missing key \(key.stringValue) at \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                
            case .dataCorrupted(let context):
                print("DATA CORRUPTED: \(context.debugDescription)")
                if let underlyingError = context.underlyingError {
                    print("Underlying Error: \(underlyingError)")
                }
                
            @unknown default:
                print("UNKNOWN DECODING ERROR: \(error.localizedDescription)")
            }
            
            print("Full Error: \(error)")
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "Invalid encoding")")
            throw NetworkError.decodingError
        } catch {
            print("🚨 Unexpected Error: \(error.localizedDescription)")
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
        case 409: throw NetworkError.duplicateReview
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
