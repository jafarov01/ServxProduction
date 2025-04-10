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
                    .navigationDestination(for: ServiceCategory.self) {
                        category in
                        SubcategoriesListView(
                            category: category,
                            viewModel: SubcategoriesViewModel(
                                category: category
                            )
                        )
                    }
                    .navigationDestination(for: Subcategory.self) {
                        subcategory in
                        ServicesListView(
                            subcategory: subcategory,
                            viewModel: ServicesViewModel(
                                subcategory: subcategory
                            )
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

            NavigationStack(path: $navManager.morePath) {
                            MoreView()
                                .navigationDestination(for: MoreRoute.self) { route in
                                    switch route {
                                    case .profile: ProfileView()
                                    case .editProfile: ProfileEditView()
                                    case .photoEdit: ProfilePhotoEditView()
                                    case .settings: SettingsView()
                                    case .support: SupportView()
                                    case .becomeProvider: BecomeServiceProviderView()
                                    case .manageServices: ManageServicesView()
                                    }
                                }
                        }
                        .tabItem { Label("More", systemImage: "ellipsis.circle") }
                        .tag(Tab.more)
        }
        .onChange(of: navManager.selectedTab) {
            navManager.resetMainNavigation()
        }
    }
}
