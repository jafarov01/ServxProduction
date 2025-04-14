//
//  ServicesListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct ServicesListView: View {
    let subcategory: ServiceArea
    @ObservedObject var viewModel: ServicesViewModel
    @EnvironmentObject private var navigator: NavigationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                searchField
                contentState
            }
            .padding(.vertical)
        }
        .navigationTitle(subcategory.name)
        .task {
            if viewModel.services.isEmpty {
                await viewModel.loadServices()
            }
        }
    }
    
    private var searchField: some View {
        ServxInputView(
            text: $viewModel.searchQuery,
            placeholder: "Search services...",
            frameColor: Color("greyScale400"),
            backgroundColor: Color("greyScale100"),
            textColor: Color("greyScale900")
        )
        .padding(.horizontal, 20)
    }
    
    private var loadingState: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding(.top, 40)
            
            Text("Loading services...")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    @ViewBuilder
    private var contentState: some View {
        if viewModel.isLoading {
            ProgressView()
                .scaleEffect(1.5)
                .padding(.top, 40)
        } else if let error = viewModel.errorMessage {
            errorState(error: error)
        } else if viewModel.services.isEmpty {
            emptyState
        } else {
            servicesList
        }
    }
    
    private func errorState(error: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
            
            Text(error)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding()
        }
    }
    
    private var emptyState: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .padding()
            
            Text("No services available for \(subcategory.name)")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding(.top, 40)
    }
    
    private var servicesList: some View {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredServices) { service in
                    ServiceDetailedCard(service: service)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            // Handle service selection
                        }
                }
            }
            .transition(.opacity)
        }
}
