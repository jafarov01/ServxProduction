//
//  Endpoint.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

/// Defines all API endpoints in a centralized manner
enum Endpoint {
    case authLogin(body: LoginRequest)
    case registerSeeker(body: RegisterSeekerRequest)
    case registerProvider(body: RegisterProviderRequest)
    case serviceCategories
    case serviceAreas(categoryId: Int)

    var url: String {
        let baseURL = "http://localhost:8080/api/"
        switch self {
        case .authLogin:
            return "\(baseURL)auth/login"
        case .registerSeeker:
            return "\(baseURL)auth/register/seeker"
        case .registerProvider:
            return "\(baseURL)auth/register/provider"
        case .serviceCategories:
            return "\(baseURL)services/categories"
        case .serviceAreas(let categoryId): // Handle categoryId for serviceAreas endpoint
            return "\(baseURL)services/areas/\(categoryId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .authLogin, .registerSeeker, .registerProvider:
            return .post
        case .serviceCategories, .serviceAreas:
            return .get
        }
    }

    var body: Encodable? {
        switch self {
        case .authLogin(let body):
            return body
        case .registerSeeker(let body):
            return body
        case .registerProvider(let body):
            return body
        case .serviceCategories, .serviceAreas:
            return nil
        }
    }
}
