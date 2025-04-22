//
//  MainTabView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 05..
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var navigator: NavigationManager
    @EnvironmentObject private var session: UserSessionManager
    
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var moreViewModel = MoreViewModel()
    @StateObject private var bookingViewModel = BookingViewModel(authenticatedUser: AuthenticatedUser.shared)

    var body: some View {
        TabView(selection: $navigator.selectedTab) {
            homeTab
            bookingTab
            calendarTab
            inboxTab
            moreTab
        }
        .tint(Color("primary500"))
        .onChange(of: navigator.selectedTab) {
            navigator.resetAllStacks()
        }
    }

    private var homeTab: some View {
        NavigationStack(path: $navigator.mainStack) {
            HomeView(viewModel: homeViewModel)
                .environmentObject(navigator)
                .navigationDestination(for: AppRoute.Main.self) { route in
                    switch route {
                    case .category(let category):
                        SubcategoriesListView(
                            category: category
                        )
                    case .subcategory(let subcategory):
                        ServicesListView(
                            subcategory: subcategory
                        )
                    case .serviceRequest(let service):
                        RequestServiceView(serviceProfile: service)
                    case .notifications:
                        NotificationListView()
                    case .serviceRequestDetail(let id):
                        ServiceRequestDetailView(requestId: id)
                    case .bookingDetail:
                        Text("BookingDetailView")
                    case .serviceReview:
                        Text("ServiceReviewView")
                    }
                }
        }
        .tabItem { Label("Home", systemImage: "house.fill") }
        .tag(Tab.home)
    }

    private var bookingTab: some View {
        NavigationStack {
            BookingView(viewModel: bookingViewModel)
        }
        .tabItem { Label("Booking", systemImage: "calendar.badge.plus") }
        .tag(Tab.booking)
    }

    private var calendarTab: some View {
        NavigationStack {
            CalendarView()
        }
        .tabItem { Label("Calendar", systemImage: "calendar.circle") }
        .tag(Tab.calendar)
    }

    private var inboxTab: some View {
        NavigationStack(path: $navigator.inboxStack) {
            InboxView()
                .navigationDestination(for: AppRoute.Inbox.self) { route in
                    switch route {
                    case .chat(let requestId):
                        ChatView(requestId: requestId)
                    }
                }
        }
        .tabItem { Label("Inbox", systemImage: "tray") }
        .tag(Tab.inbox)
    }

    private var moreTab: some View {
        NavigationStack(path: $navigator.moreStack) {
            MoreView(viewModel: MoreViewModel())
                .navigationDestination(for: AppRoute.More.self) { route in
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
}
