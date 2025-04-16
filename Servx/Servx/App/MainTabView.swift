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
            HomeView(viewModel: HomeViewModel())
                .environmentObject(navigator)
                .navigationDestination(for: AppRoute.Main.self) { route in
                    switch route {
                    case .category(let category):
                        SubcategoriesListView(
                            category: category,
                            viewModel: SubcategoriesViewModel(
                                category: category
                            )
                        )
                    case .subcategory(let subcategory):
                        ServicesListView(
                            subcategory: subcategory,
                            viewModel: ServicesViewModel(
                                subcategory: subcategory
                            )
                        )
                    case .serviceRequest(let service):
                        RequestServiceView(
                            viewModel: RequestServiceViewModel(service: service)
                        )
                    case .notifications:
                        NotificationListView(viewModel: NotificationViewModel())
                    case .serviceRequestDetail(let id):
                        Text("ServiceRequestDetail")
                    case .bookingDetail(let id):
                        Text("BookingDetailView")
                    case .serviceReview(let bookingId):
                        Text("ServiceReviewView")
                    }
                }
        }
        .tabItem { Label("Home", systemImage: "house.fill") }
        .tag(Tab.home)
    }

    private var bookingTab: some View {
        NavigationStack {
            BookingView()
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
        NavigationStack {
            InboxView()
        }
        .tabItem { Label("Inbox", systemImage: "tray") }
        .tag(Tab.inbox)
    }

    private var moreTab: some View {
        NavigationStack(path: $navigator.moreStack) {
            MoreView(viewModel: MoreViewModel())
                .navigationDestination(for: AppRoute.More.self) { route in
                    switch route {
                    case .profile: ProfileView(viewModel: ProfileViewModel())
                    case .editProfile:
                        ProfileEditView(viewModel: ProfileEditViewModel())
                    case .photoEdit:
                        ProfilePhotoEditView(
                            photoEditVM: ProfilePhotoEditViewModel(),
                            photoVM: ProfilePhotoViewModel()
                        )
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
