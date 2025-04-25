//
//  SearchResultsViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 24..
//

import SwiftUI

@MainActor
class SearchResultsViewModel: ObservableObject {
    let searchTerm: String
    @Published private(set) var results: [ServiceProfile] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String? = nil

    private let service: ServicesServiceProtocol 

    init(searchTerm: String, service: ServicesServiceProtocol = ServicesService()) {
        self.searchTerm = searchTerm
        self.service = service
         print("SearchResultsViewModel initialized for term: \(searchTerm)")
    }

    func performSearch() async {
        guard !isLoading else { return }

        print("SearchResultsViewModel: Performing search for '\(searchTerm)'...")
        isLoading = true
        errorMessage = nil
        self.results = []

        do {
            let foundServices = try await service.searchServices(query: searchTerm)
            self.results = foundServices
            print("SearchResultsViewModel: Found \(foundServices.count) results.")

        } catch let error as NetworkError {
             let errorDesc = error.localizedDescription
             print("SearchResultsViewModel: Search failed (NetworkError) - \(errorDesc)")
             self.errorMessage = "Search failed: \(errorDesc)"
             self.results = []
        } catch {
            let errorDesc = error.localizedDescription
            print("SearchResultsViewModel: Search failed (Unknown Error) - \(errorDesc)")
            self.errorMessage = "An unexpected error occurred during search."
            self.results = []
        }

        isLoading = false
    }
}
