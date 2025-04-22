//
//  MoreView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var navigator: NavigationManager
    @EnvironmentObject private var session: UserSessionManager
    @ObservedObject private var viewModel : MoreViewModel
    @ObservedObject private var auth = AuthenticatedUser.shared
    
    init(viewModel: MoreViewModel) {
            self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            Section { profileHeader }
            Section { commonOptions }
            Section { roleSpecificOptions }
            Section { logoutOption }
        }
        .navigationTitle("More")
        .task { viewModel.setupObservers() }
        .debugRender("MoreView")
    }
    
    @ViewBuilder
    private var profileHeader: some View {
        if let user = viewModel.user {
            Button {
                navigator.navigate(to: AppRoute.More.profile)
            } label: {
                HStack {
                    ProfilePhotoView(imageUrl: auth.currentUser?.profilePhotoUrl)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading) {
                        Text(user.fullName)
                            .font(.headline)
                        Text(user.role.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private var commonOptions: some View {
        Group {
            Button {
                navigator.navigate(to: AppRoute.More.settings)
            } label: {
                Label("Settings", systemImage: "gear")
            }
            
            Button {
                navigator.navigate(to: AppRoute.More.support)
            } label: {
                Label("Support", systemImage: "questionmark.circle")
            }
        }
    }
    
    @ViewBuilder
    private var roleSpecificOptions: some View {
        if let role = viewModel.user?.role {
            if role == .serviceSeeker {
                Button {
                    navigator.navigate(to: AppRoute.More.becomeProvider)
                } label: {
                    Label("Become Provider", systemImage: "arrowshape.up")
                }
            }
            
            if role == .serviceProvider {
                Button {
                    navigator.navigate(to: AppRoute.More.manageServices)
                } label: {
                    Label("Manage Services", systemImage: "briefcase")
                }
            }
        }
    }
    
    private var logoutOption: some View {
        Button(role: .destructive) {
            Task {
                await session.logout()
                navigator.resetAllStacks()
            }
        } label: {
            Label("Log Out", systemImage: "door.left.hand.open")
        }
    }
}
