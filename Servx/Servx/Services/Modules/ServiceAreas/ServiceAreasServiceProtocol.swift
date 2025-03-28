//
//  ServiceAreasServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

protocol ServiceAreaServiceProtocol {
    /// Fetches service profiles for a specific service area
    /// - Parameter areaId: ID of the service area
    /// - Returns: Array of ServiceProfile objects
    func fetchServices(for areaId: Int64) async throws -> [ServiceProfile]
}
