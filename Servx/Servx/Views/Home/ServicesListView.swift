//
//  ServicesListView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 03. 29..
//

import SwiftUI

struct ServicesListView: View {
    let subcategory: ServiceArea
    @StateObject private var viewModel: ServicesViewModel
    @EnvironmentObject private var navigator: NavigationManager

    init(subcategory: ServiceArea) {
        self.subcategory = subcategory
        _viewModel = StateObject(wrappedValue: ServicesViewModel(subcategory: subcategory))
        print("ServicesListView initialized for subcategory: \(subcategory.name)")
    }

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
        // --- CHANGE: Use .alert(item: ...) ---
        .alert(item: $viewModel.errorWrapper) { wrapper in
             // SwiftUI automatically handles presenting when errorWrapper is non-nil
             // and setting it back to nil on dismissal.
            Alert(
                title: Text("Error"),
                message: Text(wrapper.message), // Use message from the wrapper
                dismissButton: .default(Text("OK"))
            )
        }
        // --- End Change ---
    }

    // searchField remains the same
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


    // contentState remains the same, checking errorWrapper now
     @ViewBuilder
     private var contentState: some View {
         if viewModel.isLoading {
             ProgressView("Loading...")
                 .padding(.top, 40) // Added padding back
         } else if viewModel.errorWrapper != nil {
             // Just show a simple placeholder or retry, alert shows the detail
              errorStatePlaceholder // Use placeholder view
         } else if viewModel.filteredServices.isEmpty && !viewModel.searchQuery.isEmpty {
             noSearchResultsState
         } else if viewModel.services.isEmpty {
             emptyState
         } else {
             servicesList
         }
     }
     
     // Optional: Placeholder shown while alert is potentially visible
     private var errorStatePlaceholder: some View {
         VStack {
             Image(systemName: "exclamationmark.triangle")
                 .font(.largeTitle)
                 .foregroundColor(.orange)
                 .padding()
             Text("Could not load services.")
                 .foregroundColor(.secondary)
             Button("Retry") {
                 Task { await viewModel.loadServices() }
             }
             .padding(.top)
         }
         .padding()
     }

    private var emptyState: some View {
        VStack {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .padding()

            Text("No services found for \(subcategory.name)")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding(.top, 40)
    }
    
    private var noSearchResultsState: some View {
         VStack {
             Image(systemName: "magnifyingglass")
                 .font(.largeTitle)
                 .foregroundColor(.gray)
                 .padding()
             Text("No services found matching '\(viewModel.searchQuery)'")
                 .multilineTextAlignment(.center)
                 .foregroundColor(.gray)
         }
         .padding(.top, 40)
     }


    private var servicesList: some View {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredServices) { service in
                    
                    Button {
                         print("Navigating to service request for: \(service.providerName)")
                         navigator.navigate(to: AppRoute.Main.serviceRequest(service))
                    } label: {
                         ServiceDetailedCard(service: service)
                             .padding(.horizontal, 20)
                    }
                     .buttonStyle(PlainButtonStyle())
                }
            }
            .transition(.opacity)
    }
}
