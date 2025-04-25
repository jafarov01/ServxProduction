//
//  SearchResultsView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 24..
//

import SwiftUI

struct SearchResultsView: View {
    let searchTerm: String
    @StateObject private var viewModel: SearchResultsViewModel

    @EnvironmentObject private var navigator: NavigationManager

    init(searchTerm: String) {
        self.searchTerm = searchTerm
        _viewModel = StateObject(
            wrappedValue: SearchResultsViewModel(searchTerm: searchTerm)
        )
        print("SearchResultsView initialized with term: \(searchTerm)")
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.results.isEmpty {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else if viewModel.results.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No results found")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text("No services matched '\(searchTerm)'")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.results) { serviceProfile in
                            
                            Button {
                                 print("Navigating to service request for: \(serviceProfile.providerName)")
                                 navigator.navigate(to: AppRoute.Main.serviceProfileDetail(serviceProfile))
                            } label: {
                                 ServiceDetailedCard(service: serviceProfile)
                                    .listRowInsets(
                                        EdgeInsets(
                                            top: 8,
                                            leading: 16,
                                            bottom: 8,
                                            trailing: 16
                                        )
                                    )
                                    .listRowSeparator(.hidden)
                                    .contentShape(Rectangle())
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            if viewModel.isLoading && !viewModel.results.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: .accentColor)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            }
        }
        .navigationTitle("Results for '\(searchTerm)'")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navigator.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("primary500"))
                        .fontWeight(.medium)
                }
            }
        }
        .task {
            if viewModel.results.isEmpty && !viewModel.isLoading {
                await viewModel.performSearch()
            }
        }
        .debugRender("SearchResultsView")
    }
}
