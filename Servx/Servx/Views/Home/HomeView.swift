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
    @EnvironmentObject private var navigator: NavigationManager
    
    init(viewModel: HomeViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                contentView
            }
        }
        .task(id: navigator.selectedTab) {
            if navigator.selectedTab == .home && viewModel.shouldLoadData {
                await viewModel.loadData()
            }
        }
        .navigationBarBackButtonHidden()
        .debugRender("HomeView")
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderView()
                
                ServxInputView(
                    text: $searchInput,
                    placeholder: "Search for services",
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

struct CategoriesSection: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var navigator: NavigationManager
    private let gridColumns = [GridItem(.adaptive(minimum: 80))]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(
                title: "Category",
                actionTitle: "View all",
                action: { /* Handle category view all */ }
            )
            
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(viewModel.categories) { category in
                    Button {
                        navigator.navigate(to: AppRoute.Main.category(category))
                    } label: {
                        CategoryCard(category: category)
                    }
                }
            }
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject private var navigator: NavigationManager
    
    var body: some View {
        HStack {
            ProfilePhotoView(imageUrl: AuthenticatedUser.shared.currentUser?.profilePhotoUrl)
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .stroke(ServxTheme.inputFieldBorderColor, lineWidth: 2)
                )
            
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
                .onTapGesture {
                    navigator.navigate(to: AppRoute.Main.notifications)  // Navigate to NotificationListView
                }
            
            Image("bookmarkIcon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 28, height: 28)
        }
        .padding(.horizontal, 20)
    }
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

struct RecommendedServicesSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(
                title: "Recommended Services",
                actionTitle: "View all",
                action: { /* Handle services view all */ }
            )
            .padding(.top, 32)
            
            LazyVStack(spacing: 16) {
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
                    weight: .regular,
                    alignment: .trailing
                )
                .onTapGesture(perform: action)
            }
        }
    }
}

extension View {
    /// Logs when the view's body is recomputed
    func debugRender(_ tag: String) -> some View {
        viewLogger.info("issue01: \(tag) re-rendered")
        return self
    }
}
