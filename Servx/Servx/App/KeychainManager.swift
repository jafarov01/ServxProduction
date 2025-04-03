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
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecValueData: token.data(using: .utf8)!,
            kSecAttrAccessible: accessible
        ]
        
        // Delete existing item before adding new
        try deleteToken(service: service)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }
    
    static func getToken(service: String) throws -> String? {
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
            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                throw KeychainError.invalidDataFormat
            }
            return token
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.loadFailed(status: status)
        }
    }
    
    static func deleteToken(service: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
}

enum KeychainError: Error, LocalizedError {
    case saveFailed(status: OSStatus)
    case loadFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case invalidDataFormat
    
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
        }
    }
}
