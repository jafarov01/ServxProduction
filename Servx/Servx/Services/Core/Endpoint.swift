//
//  Endpoint.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

enum Endpoint {
    case authLogin(body: LoginRequest)
    case register(body: RegisterRequest)
    case fetchCategories
    case fetchRecommendedServices
    case fetchSubcategories(categoryId: Int64)
    case fetchServices(categoryId: Int64, subcategoryId: Int64)
    case getUserDetails
    case fetchUserDetails(userId: Int64)
    case updateProfilePhoto
    case deleteProfilePhoto
    
    var requiresAuth: Bool {
        switch self {
        case .authLogin, .register:
            return false
        default:
            return true
        }
    }
    
    var url: String {
        let baseURL = "http://localhost:8080/api/"
        switch self {
        case .updateProfilePhoto: return "\(baseURL)user/me/photo"
        case .deleteProfilePhoto: return "\(baseURL)user/me/photo"
        case .authLogin: return "\(baseURL)auth/login"
        case .register: return "\(baseURL)auth/register"
        case .getUserDetails: return "\(baseURL)user/me"
        case .fetchCategories: return "\(baseURL)categories"
        case .fetchRecommendedServices: return "\(baseURL)service-offers/recommended"
        case .fetchSubcategories(let categoryId):
            return "\(baseURL)categories/\(categoryId)/subcategories"
        case .fetchServices(let categoryId, let subcategoryId):
            return "\(baseURL)categories/\(categoryId)/subcategories/\(subcategoryId)/service-offers"
        case .fetchUserDetails(let userId):
            return "\(baseURL)users/\(userId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .authLogin, .register:
            return .post
        case .updateProfilePhoto:
            return .get
        case .deleteProfilePhoto:
            return .delete
        default:
            return .get
        }
    }
    
    var body: APIRequest? {
        switch self {
        case .authLogin(let body):
            return body as APIRequest
        case .register(let body):
            return body as APIRequest
        default:
            return nil
        }
    }
}
