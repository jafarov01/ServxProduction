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
    case createBulkServices(
        categoryId: Int64,
        request: BulkServiceProfileRequest
    )
    case createServiceRequest(request: ServiceRequestDTO)
    case createNotification(Notification)
    case getNotifications
    case markNotificationAsRead(notificationId: Int64)
    case fetchServiceRequest(id: Int64)
    case acceptServiceRequest(id: Int64)
    case fetchConversations  // GET /api/chats
    case fetchMessages(requestId: Int64, page: Int, size: Int)
    case markConversationAsRead(requestId: Int64)
    case confirmBooking(requestId: Int64, messageId: Int64)
    case rejectBooking(requestId: Int64)
    case fetchBookings(status: BookingStatus, page: Int, size: Int)
    case cancelBooking(bookingId: Int64)
    case fetchServiceProfile(profileId: Int64)
    case fetchBookingsByDateRange(startDate: Date, endDate: Date)
    case sendSupportRequest(body: SupportRequestDTO)

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
        case .sendSupportRequest:
            return "\(baseURL)support/request"
        case .fetchServiceProfile(let profileId):
            return "\(baseURL)service-profiles/\(profileId)"
        case .fetchServiceRequest(let id):
            return "\(baseURL)service-requests/\(id)"
        case .acceptServiceRequest(let id):
            return "\(baseURL)service-requests/\(id)/accept"
        case .createNotification:
            return "\(baseURL)notifications"
        case .getNotifications:
            return "\(baseURL)notifications"
        case .markNotificationAsRead(let notificationId):
            return "\(baseURL)notifications/\(notificationId)/read"
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
        case .createServiceRequest:
            return "\(baseURL)service-requests"
        case .fetchConversations:
            return "\(baseURL)chats"
        case .fetchMessages(let requestId, let page, let size):
            return
                "\(baseURL)chats/\(requestId)/messages?page=\(page)&size=\(size)&sort=timestamp,desc"
        case .markConversationAsRead(let requestId):
            return "\(baseURL)chats/\(requestId)/read"
        case .confirmBooking(let requestId, let messageId):  // Updated path
            return
                "\(baseURL)service-requests/\(requestId)/confirm-booking/\(messageId)"
        case .rejectBooking(let requestId):
            return "\(baseURL)service-requests/\(requestId)/reject-booking"
        case .fetchBookings(let status, let page, let size):
            let statusQuery = "status=\(status.rawValue)"  // Use backend status values
            let pageQuery = "page=\(page)"
            let sizeQuery = "size=\(size)"
            // Match the sort parameter used in @PageableDefault in controller
            let sortQuery = "sort=scheduledStartTime,asc"
            return
                "\(baseURL)bookings?\(statusQuery)&\(pageQuery)&\(sizeQuery)&\(sortQuery)"
        case .cancelBooking(let bookingId):
            return "\(baseURL)bookings/\(bookingId)/cancel"
        case .fetchBookingsByDateRange(let startDate, let endDate):
            let startDateString = DateFormatter.yyyyMMdd.string(from: startDate)
            let endDateString = DateFormatter.yyyyMMdd.string(from: endDate)
            // Use ascending sort for calendar view typically
            let sortQuery = "sort=scheduledStartTime,asc"
            // Construct the URL for the assumed backend endpoint
            return
                "\(baseURL)bookings/by-date?startDate=\(startDateString)&endDate=\(endDateString)&\(sortQuery)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .authLogin, .register, .upgradeToProvider, .createServiceProfile,
            .createBulkServices, .createServiceRequest, .createNotification,
            .confirmBooking, .rejectBooking, .cancelBooking, .sendSupportRequest:
            return .post
        case .updateProfilePhoto, .updateUserDetails:
            return .put
        case .deleteProfilePhoto:
            return .delete
        case .markNotificationAsRead, .acceptServiceRequest,
            .markConversationAsRead:
            return .patch
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
        case .createServiceRequest(let request):
            return request
        case .createNotification(let notification):
            return notification
        case .sendSupportRequest(let body): // *** ADD body ***
            return body
        default:
            return nil
        }
    }
}
