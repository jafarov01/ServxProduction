//
//  HomeView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 18/07/2024.
//
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State private var searchInput: String = ""
    @ObservedObject private var viewModel: HomeViewModel
    @EnvironmentObject private var navigationManager: NavigationManager

    // Dependency Injection for ViewModel
    init(viewModel: HomeViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    let itemsPerRow = 4

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        HeaderView()

                        // Search input with top padding
                        ServxInputView(
                            text: $searchInput,
                            placeholder: "Search for services",
                            isSecure: false,
                            frameWidth: nil,
                            frameColor: Color("greyScale400"),
                            backgroundColor: Color("greyScale100"),
                            textColor: Color("greyScale900")
                        )
                        .padding(.top, 20)

                        HorizontalScrollView()

                        CategoriesSection(viewModel: viewModel)

                        RecommendedServicesSection(viewModel: viewModel)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func HorizontalScrollView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<10) { index in
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color("primary300"))
                        .frame(width: 280, height: 134)
                        .padding(10)
                        .overlay(
                            Text("This is the \(index)th page here")
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            // Profile photo on the left
            //ProfilePhotoView(viewModel: HomeViewModel().profilePhotoViewModel, width: 48, height: 48)

            VStack(alignment: .leading) {
                // Greeting text
                ServxTextView(
                    text: "Good Morning 👋🏻",
                    color: Color("greyScale900"),
                    size: 14,
                    weight: .regular,
                    alignment: .leading
                )
                
                // User's full name
                ServxTextView(
                    text: AuthenticatedUser.shared.fullName,
                    color: Color("primary500"),
                    size: 18,
                    weight: .bold,
                    alignment: .leading
                )
            }

            Spacer()

            // Notification and bookmark icons
            Image("notificationIcon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 28, height: 28)
                .padding(.horizontal, 16)

            Image("bookmarkIcon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 28, height: 28)
        }
        .padding(.horizontal, 20)
    }
}

struct CategoriesSection: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var navigationManager: NavigationManager

    let itemsPerRow = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ServxTextView(
                    text: "Category",
                    color: Color("greyScale900"),
                    size: 18,
                    weight: .bold,
                    alignment: .leading
                )
                
                Spacer()
                
                ServxTextView(
                    text: "View all",
                    color: Color("primary500"),
                    size: 14,
                    weight: .regular,
                    alignment: .leading
                )
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: Array(repeating: GridItem(), count: itemsPerRow), spacing: 10) {
                ForEach(viewModel.categories) { category in
                    Button(action: {
                        navigationManager.navigate(to: .subcategories(category: category))
                    }) {
                        CategoryCard(category: category)
                    }
                }
            }
        }
    }
}

struct RecommendedServicesSection: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ServxTextView(
                    text: "Recommended Services",
                    color: Color("greyScale900"),
                    size: 18,
                    weight: .bold,
                    alignment: .leading
                )

                Spacer()

                ServxTextView(
                    text: "View all",
                    color: Color("primary500"),
                    size: 14,
                    weight: .regular,
                    alignment: .leading
                )
                .onTapGesture {
                    // Handle View All action
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)

            // Add services here
            VStack(spacing: 16) {
                ForEach(viewModel.recommendedServices) { service in
                    ServiceDetailedCard(service: service)
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            ServxTextView(
                text: title,
                color: Color("greyScale900"),
                size: 18,
                weight: .bold,
                alignment: .leading
            )
            Spacer()
            if let actionTitle = actionTitle, let action = action {
                ServxTextView(
                    text: actionTitle,
                    color: Color("primary500"),
                    size: 14,
                    alignment: .leading
                )
                .onTapGesture(perform: action)
            }
        }
    }
}
