//
//  KeychainManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 02..
//


import Security
import Foundation

protocol KeychainManagerProtocol {
    static func save(token: String, service: String) throws
    static func getToken(service: String) throws -> String?
    static func deleteToken(service: String) throws
}

struct KeychainManager: KeychainManagerProtocol {
    private static let accessible = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    
    static func save(token: String, service: String) throws {
        print("===== KeychainManager.save called =====")
        print("Saving token for service: \(service)")

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecValueData: token.data(using: .utf8)!,
            kSecAttrAccessible: accessible
        ]
        
        print("Attempting to delete existing token for service: \(service)")
        try deleteToken(service: service)

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("Token successfully saved for service: \(service)")
        } else {
            print("Failed to save token for service: \(service), OSStatus: \(status)")
            throw KeychainError.saveFailed(status: status)
        }
    }
    
    static func getToken(service: String) throws -> String? {
        print("===== KeychainManager.getToken called =====")
        print("Fetching token for service: \(service)")
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            print("Token found for service: \(service)")
            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                print("Failed to decode token for service: \(service)")
                throw KeychainError.invalidDataFormat
            }
            return token
        case errSecItemNotFound:
            print("No token found for service: \(service)")
            return nil
        default:
            print("Failed to load token for service: \(service), OSStatus: \(status)")
            throw KeychainError.loadFailed(status: status)
        }
    }
    
    static func deleteToken(service: String) throws {
        print("===== KeychainManager.deleteToken called =====")
        print("Deleting token for service: \(service)")
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            print("Token successfully deleted for service: \(service)")
        } else {
            print("Failed to delete token for service: \(service), OSStatus: \(status)")
            throw KeychainError.deleteFailed(status: status)
        }
    }
}

enum KeychainError: Error, LocalizedError {
    case saveFailed(status: OSStatus)
    case loadFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case invalidDataFormat
    case tokenNotFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save token (OSStatus: \(status))"
        case .loadFailed(let status):
            return "Failed to load token (OSStatus: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete token (OSStatus: \(status))"
        case .invalidDataFormat:
            return "Token data format is invalid"
        case .tokenNotFound:
            return "Token not found"
        }
    }
}
