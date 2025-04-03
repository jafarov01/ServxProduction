//
//  ServiceCategoryServiceProtocol.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 20..
//

import Foundation

protocol ServicesServiceProtocol {
    func fetchCategories() async throws -> [ServiceCategory]
    func fetchRecommendedServices() async throws -> [ServiceProfile]
    func fetchSubcategories(categoryId: Int64) async throws -> [Subcategory]
    func fetchServices(categoryId: Int64, subcategoryId: Int64) async throws -> [ServiceProfile]
    func fetchUserName(userId: Int64) async throws -> String
}
