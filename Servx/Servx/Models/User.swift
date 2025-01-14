//
//  User.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 11..
//

import Foundation

struct User {
    let id: String
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let address: Address
    let languagesSpoken : [String]
    
    // Service profiles for this user
    var serviceProfiles: [ServiceProfile]
    
    // A user is always a seeker
    var isSeeker: Bool { true }
}
