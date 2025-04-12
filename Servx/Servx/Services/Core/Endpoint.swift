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
    case updateUserDetails(request: UpdateUserRequest)
    case upgradeToProvider(request: UpgradeToProviderRequestDTO)
    case createServiceProfile(request: ServiceProfileRequestDTO)
    case createBulkServices(categoryId: Int64, request: BulkServiceProfileRequest)

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
        case .createBulkServices(let categoryId, _):
            return "\(baseURL)categories/\(categoryId)/service-offers/bulk"
        case .updateProfilePhoto: return "\(baseURL)user/me/photo"
        case .deleteProfilePhoto: return "\(baseURL)user/me/photo"
        case .authLogin: return "\(baseURL)auth/login"
        case .updateUserDetails: return "\(baseURL)user/me"
        case .register: return "\(baseURL)auth/register"
        case .getUserDetails: return "\(baseURL)user/me"
        case .fetchCategories: return "\(baseURL)categories"
        case .fetchRecommendedServices:
            return "\(baseURL)service-offers/recommended"
        case .upgradeToProvider:
            return "\(baseURL)user/me/upgrade-to-provider"
        case .fetchSubcategories(let categoryId):
            return "\(baseURL)categories/\(categoryId)/subcategories"
        case .fetchServices(let categoryId, let subcategoryId):
            return
                "\(baseURL)categories/\(categoryId)/subcategories/\(subcategoryId)/service-offers"
        case .fetchUserDetails(let userId):
            return "\(baseURL)users/\(userId)"
        case .createServiceProfile:
            return "\(baseURL)user/me/service-profile"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .authLogin, .register, .upgradeToProvider, .createServiceProfile, .createBulkServices:
            return .post
        case .updateProfilePhoto, .updateUserDetails:
            return .put
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
        case .updateUserDetails(let request):
            return request
        case .upgradeToProvider(let request):
            return request
        case .createServiceProfile(let request):
            return request
        case .createBulkServices(_, let request):
            return request
        default:
            return nil
        }
    }
}
