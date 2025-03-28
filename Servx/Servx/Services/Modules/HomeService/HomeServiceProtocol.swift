//
//  HomeServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 12..
//

protocol HomeServiceProtocol {
    /// Fetch all fixed service categories configured by admin
    func fetchServiceCategories() async throws -> [ServiceCategory]
}
