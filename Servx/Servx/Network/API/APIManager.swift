//
//  APIManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 03..
//

import Foundation
import Combine

class APIManager {
    static let shared = APIManager()
    private init() {}

    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: endpoint.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw NetworkError.invalidResponse
                }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { NetworkError.map($0) }
            .eraseToAnyPublisher()
    }
}
