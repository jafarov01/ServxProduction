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
    
    let promotionCards: [PromotionCardData] = [
        PromotionCardData(headline: "Welcome to Servx!",
                          imageName: "promo_welcome"),
        PromotionCardData(headline: "Grow Your Business!",
                          imageName: "promo_provider_free"),
        PromotionCardData(headline: "Find Help, Zero Fees!",
                          imageName: "promo_seeker_free"),
        PromotionCardData(headline: "We're Just Getting Started!",
                          imageName: "promo_features"),
        PromotionCardData(headline: "Support Your Local Pros!",
                          imageName: "promo_community")
    ]
    
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
                .onSubmit {
                    triggerSearch()
                }
                
                PromotionsScrollView(promotions: promotionCards)
                     .padding(.vertical)
                CategoriesSection(viewModel: viewModel)
                RecommendedServicesSection(viewModel: viewModel)
            }
            .padding(.horizontal, 20)
        }
        
    }
    
    private func triggerSearch() {
        let trimmedQuery = searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        print("HomeView: Triggering search for '\(trimmedQuery)'")
        guard !trimmedQuery.isEmpty else {
            print("HomeView: Search query is empty, not navigating.")
            return
        }
        navigator.navigate(to: AppRoute.Main.searchView(searchTerm: trimmedQuery))
    }
}

struct CategoriesSection: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var navigator: NavigationManager
    private let gridColumns = [GridItem(.adaptive(minimum: 80))]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
    
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning ☀️"
        case 12..<18:
            return "Good Afternoon 👋🏻"
        default:
            return "Good Evening 🌙"
        }
    }
    
    var body: some View {
        HStack {
            HStack {
                ProfilePhotoView(imageUrl: AuthenticatedUser.shared.currentUser?.profilePhotoUrl)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(ServxTheme.inputFieldBorderColor, lineWidth: 2)
                    )
                
                VStack(alignment: .leading) {
                    ServxTextView(
                        text: timeBasedGreeting,
                        color: Color("greyScale900"),
                        size: 14,
                        weight: .regular,
                        alignment: .leading
                    )
                    
                    ServxTextView(
                        text: AuthenticatedUser.shared.fullName,
                        color: Color("primary500"),
                        size: 18,
                        weight: .bold,
                        alignment: .leading
                    )
                }
            }
            .onTapGesture(perform: {
                navigator.switchTab(to: .more)
                navigator.navigate(to: AppRoute.More.profile)
            })
            
            Spacer()
            
            Image("notificationIcon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 28, height: 28)
                .padding(.horizontal, 16)
                .onTapGesture {
                    navigator.navigate(to: AppRoute.Main.notifications)
                }
        }
        .padding(.horizontal, 20)
    }
}

struct PromotionsScrollView: View {
    let promotions: [PromotionCardData]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(promotions) { cardData in
                    PromotionCardView(data: cardData)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct RecommendedServicesSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
    func debugRender(_ tag: String) -> some View {
        viewLogger.info("issue01: \(tag) re-rendered")
        return self
    }
}

struct PromotionCardData: Identifiable {
    let id = UUID()
    let headline: String
    let imageName: String
}

struct PromotionCardView: View {
    let data: PromotionCardData
    
    var body: some View {
        ZStack {
            Image(data.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 280, height: 134)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0.6), .black.opacity(0.1)]),
                        startPoint: .bottom,
                        endPoint: .center
                    )
                )
                .clipped()
                
            VStack(alignment: .leading) {
                Spacer()
                Text(data.headline)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(width: 280, height: 134)
        .background(Color("primary300"))
        .cornerRadius(24)
        .shadow(radius: 3)
    }
}
