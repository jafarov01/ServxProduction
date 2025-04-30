//
//  Endpoint.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

enum NetworkConstants {
    static let baseURL = "http://localhost:8080"
    static let uploadsPath = "/uploads/"
}

enum Endpoint {

    // MARK: - Authentication
    case authLogin(body: LoginRequest)
    case register(body: RegisterRequest)
    case forgotPassword(body: ForgotPasswordRequest)

    // MARK: - User Profile & Actions
    case getUserDetails // Fetches authenticated user's own details
    case updateUserDetails(request: UpdateUserRequest) // Updates own details
    case updateProfilePhoto // Uploads own photo
    case deleteProfilePhoto // Deletes own photo
    case upgradeToProvider(request: UpgradeToProviderRequestDTO) // Upgrade own role
    case fetchUserDetails(userId: Int64) // Fetch specific user

    // MARK: - Service Categories & Areas
    case fetchCategories
    case fetchSubcategories(categoryId: Int64)
    case searchServices(query: String)

    // MARK: - Service Profiles (Provider Offerings)
    case fetchServices(categoryId: Int64, subcategoryId: Int64) // Fetch list by subcategory
    case fetchServiceProfile(profileId: Int64) // Fetch specific profile by its ID
    case createServiceProfile(request: ServiceProfileRequestDTO) // Create one profile
    case createBulkServices(categoryId: Int64, request: BulkServiceProfileRequest) // Create multiple
    case fetchRecommendedServices

    // MARK: - Service Requests
    case createServiceRequest(request: ServiceRequestDTO)
    case fetchServiceRequest(id: Int64) // Get details of one request
    case acceptServiceRequest(id: Int64) // Provider accepts
    case confirmBooking(requestId: Int64, messageId: Int64) // Seeker confirms booking from chat
    case rejectBooking(requestId: Int64) // Seeker rejects booking from chat

    // MARK: - Bookings
    case fetchBookings(status: BookingStatus, page: Int, size: Int) // Combined endpoint
    case fetchBookingsByDateRange(startDate: Date, endDate: Date) // For Calendar view
    case cancelBooking(bookingId: Int64) // User cancels own booking
    case providerMarkComplete(bookingId: Int64) // Provider action
    case seekerConfirmCompletion(bookingId: Int64) // Seeker action

    // MARK: - Chat
    case fetchConversations
    case fetchMessages(requestId: Int64, page: Int, size: Int)
    case markConversationAsRead(requestId: Int64)

    // MARK: - Notifications
    case getNotifications
    case markNotificationAsRead(notificationId: Int64)
    case createNotification(Notification)

    // MARK: - Reviews
    case submitReview(body: ReviewRequestDTO) // Seeker submits review
    case fetchReviewsForService(serviceId: Int64, page: Int, size: Int) // Fetch reviews for a service

    // MARK: - Support
    case sendSupportRequest(body: SupportRequestDTO)


    // --- Computed Properties ---

    /// Base URL for the API, constructed from NetworkConstants
    private var apiBaseUrl: String {
        let base = NetworkConstants.baseURL.hasSuffix("/") ? String(NetworkConstants.baseURL.dropLast()) : NetworkConstants.baseURL
        return base + "/api"
    }

    /// Determines if the endpoint requires authentication token
    var requiresAuth: Bool {
        switch self {
        // Publicly accessible endpoints
        case .authLogin, .register,
             .fetchCategories, .fetchSubcategories,
             .fetchServices, .fetchServiceProfile,
             .fetchReviewsForService, .forgotPassword:
            return false
        // All other endpoints require authentication
        default:
            return true
        }
    }

    /// Generates the full URL string for the endpoint
    var url: String {
        let base = apiBaseUrl

        switch self {
        // Auth
        case .authLogin: return "\(base)/auth/login"
        case .register: return "\(base)/auth/register"
        case .forgotPassword: return "\(base)/auth/forgot-password"

        // User
        case .getUserDetails: return "\(base)/user/me"
        case .updateUserDetails: return "\(base)/user/me"
        case .updateProfilePhoto: return "\(base)/user/me/photo"
        case .deleteProfilePhoto: return "\(base)/user/me/photo"
        case .upgradeToProvider: return "\(base)/user/me/upgrade-to-provider"
        case .fetchUserDetails(let userId): return "\(base)/users/\(userId)"

        // Categories & Services
        case .fetchCategories: return "\(base)/categories"
        case .fetchSubcategories(let categoryId): return "\(base)/categories/\(categoryId)/subcategories"
        case .fetchServices(let categoryId, let subcategoryId): return "\(base)/categories/\(categoryId)/subcategories/\(subcategoryId)/service-offers"
        case .fetchServiceProfile(let profileId):
            let arbitraryCategoryId: Int64 = 1
            return "\(base)/categories/\(arbitraryCategoryId)/\(profileId)"
        case .createServiceProfile: return "\(base)/user/me/service-profile"
        case .createBulkServices(let categoryId, _): return "\(base)/categories/\(categoryId)/service-offers/bulk"
        case .fetchRecommendedServices: return "\(base)/service-offers/recommended"
        case .searchServices: return "\(base)/services/search"

        // Service Requests
        case .createServiceRequest: return "\(base)/service-requests"
        case .fetchServiceRequest(let id): return "\(base)/service-requests/\(id)"
        case .acceptServiceRequest(let id): return "\(base)/service-requests/\(id)/accept"
        case .confirmBooking(let requestId, let messageId): return "\(base)/service-requests/\(requestId)/confirm-booking/\(messageId)"
        case .rejectBooking(let requestId): return "\(base)/service-requests/\(requestId)/reject-booking"

        // Bookings
        case .fetchBookings(let status, let page, let size):
            let query = urlQuery(params: [
                "status": status.rawValue,
                "page": "\(page)",
                "size": "\(size)",
                "sort": "scheduledStartTime,asc"
            ])
            return "\(base)/bookings?\(query)"

        case .fetchBookingsByDateRange(let startDate, let endDate):
            let query = urlQuery(params: [
                "startDate": startDate.toYYYYMMDDString(),
                "endDate": endDate.toYYYYMMDDString(),
                "sort": "scheduledStartTime,asc"
            ])
            return "\(base)/bookings/by-date?\(query)"

        case .cancelBooking(let bookingId): return "\(base)/bookings/\(bookingId)/cancel"
        case .providerMarkComplete(let bookingId): return "\(base)/bookings/\(bookingId)/provider-complete"
        case .seekerConfirmCompletion(let bookingId): return "\(base)/bookings/\(bookingId)/seeker-confirm"

        // Chat
        case .fetchConversations: return "\(base)/chats"
        case .fetchMessages(let requestId, let page, let size):
             let query = urlQuery(params: [
                 "page": "\(page)",
                 "size": "\(size)",
                 "sort": "timestamp,desc"
             ])
            return "\(base)/chats/\(requestId)/messages?\(query)"
        case .markConversationAsRead(let requestId): return "\(base)/chats/\(requestId)/read"

        // Notifications
        case .getNotifications: return "\(base)/notifications"
        case .markNotificationAsRead(let notificationId): return "\(base)/notifications/\(notificationId)/read"
        case .createNotification: return "\(base)/notifications"

        // Reviews
        case .submitReview: return "\(base)/reviews"
        case .fetchReviewsForService(let serviceId, let page, let size):
             let query = urlQuery(params: [
                 "page": "\(page)",
                 "size": "\(size)",
                 "sort": "createdAt,desc"
             ])
            return "\(base)/reviews/service/\(serviceId)?\(query)"

        // Support
        case .sendSupportRequest: return "\(base)/support/request"
        }
    }

    /// Determines the HTTP method for the endpoint
    var method: HTTPMethod {
        switch self {
        // POST
        case .authLogin, .register, .upgradeToProvider, .createServiceProfile,
             .createBulkServices, .createServiceRequest, .confirmBooking,
             .rejectBooking, .cancelBooking, .sendSupportRequest, .submitReview,
             .providerMarkComplete, .seekerConfirmCompletion, .forgotPassword:
            return .post

        // PUT
        case .updateProfilePhoto, .updateUserDetails:
            return .put

        // DELETE
        case .deleteProfilePhoto:
            return .delete

        // PATCH
        case .markNotificationAsRead, .acceptServiceRequest, .markConversationAsRead:
            return .patch

        // GET (Default)
        default:
            return .get
        }
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
            case .searchServices(let query):
                return [URLQueryItem(name: "q", value: query)]
            default:
                return nil
        }
    }

    /// Provides the request body for endpoints that require it
    var body: APIRequest? {
        switch self {
        case .authLogin(let body): return body
        case .register(let body): return body
        case .updateUserDetails(let request): return request
        case .upgradeToProvider(let request): return request
        case .createServiceProfile(let request): return request
        case .createBulkServices(_, let request): return request
        case .createServiceRequest(let request): return request
        case .createNotification(let notification): return notification
        case .sendSupportRequest(let body): return body
        case .submitReview(let body): return body
        case .forgotPassword(let body): return body

        // Endpoints without a body return nil
        default:
            return nil
        }
    }

    private func urlQuery(params: [String: String]) -> String {
         var components = URLComponents()
         components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
         return components.query ?? ""
     }
}
