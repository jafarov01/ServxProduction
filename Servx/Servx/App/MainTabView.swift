//
//  MainTabView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 05..
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var navManager: NavigationManager
    
    var body: some View {
        TabView(selection: $navManager.selectedTab) {
            // Home Tab with main navigation stack
            NavigationStack(path: $navManager.mainPath) {
                HomeView(viewModel: HomeViewModel())
                    .navigationDestination(for: ServiceCategory.self) { category in
                        SubcategoriesListView(
                            category: category,
                            viewModel: SubcategoriesViewModel(category: category)
                        )
                    }
                    .navigationDestination(for: Subcategory.self) { subcategory in
                        ServicesListView(
                            subcategory: subcategory,
                            viewModel: ServicesViewModel(subcategory: subcategory)
                        )
                    }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(Tab.home)
            
            // Independent tabs with their own navigation
            NavigationStack {
                BookingView()
            }
            .tabItem { Label("Booking", systemImage: "calendar.badge.plus") }
            .tag(Tab.booking)
            
            NavigationStack {
                CalendarView()
            }
            .tabItem { Label("Calendar", systemImage: "calendar.circle") }
            .tag(Tab.calendar)
            
            NavigationStack {
                InboxView()
            }
            .tabItem { Label("Inbox", systemImage: "tray") }
            .tag(Tab.inbox)
            
            // Profile Tab with profile navigation stack
            NavigationStack(path: $navManager.profilePath) {
                ProfileView(viewModel: ProfileViewModel())
                    .navigationDestination(for: ProfileRoute.self) { route in
                        switch route {
                        case .edit:
                            ProfilePhotoEditView(viewModel: ProfilePhotoEditViewModel())
                        case .settings:
                            SettingsView()
                        case .support:
                            SupportView()
                        }
                    }
            }
            .tabItem { Label("Profile", systemImage: "person.circle") } // ✅ Apply to NavigationStack
            .tag(Tab.profile) // ✅ Apply to NavigationStack
        }
        .onChange(of: navManager.selectedTab) {
            navManager.resetMainNavigation()
        }
    }
}
