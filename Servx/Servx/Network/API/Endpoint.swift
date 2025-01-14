//
//  Endpoint.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 03..
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

struct Endpoint {
    var path: String
    var method: HTTPMethod
    var headers: [String: String]
    var body: [String: String]?

    // Example method for seekers
    static func registerServiceSeeker() -> Endpoint {
        Endpoint(
            path: "/api/register/seeker",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: nil
        )
    }

    // Example method for providers
    static func registerServiceProvider() -> Endpoint {
        Endpoint(
            path: "/api/register/provider",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: nil
        )
    }
}
