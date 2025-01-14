//
//  RequestBuilder.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 03..
//

import Foundation

class RequestBuilder {
    static func registerSeekerPayload(seeker: ServiceSeeker) -> [String: Any] {
        [
            "email": seeker.email,
            "password": seeker.password,
            "firstName": seeker.firstName,
            "lastName": seeker.lastName,
            "phoneNumber": seeker.phoneNumber,
            "address": seeker.address,
            "country": seeker.country,
            "city": seeker.city
        ]
    }

    static func registerProviderPayload(provider: ServiceProvider) -> [String: Any] {
        [
            "email": provider.email,
            "password": provider.password,
            "firstName": provider.firstName,
            "lastName": provider.lastName,
            "phoneNumber": provider.phoneNumber,
            "address": provider.address,
            "country": provider.country,
            "city": provider.city,
            "education": provider.education,
            "serviceArea": provider.serviceArea,
            "language": provider.language,
            "workExperience": provider.workExperience
        ]
    }
}
