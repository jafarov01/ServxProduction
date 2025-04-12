//
//  MoreView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 10..
//

import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var navManager: NavigationManager
    @StateObject private var viewModel = MoreViewModel()
    
    var body: some View {
        List {
            Section { profileHeader }
            Section { commonOptions }
            Section { roleSpecificOptions }
            Section { logoutOption }
        }
        .navigationTitle("More")
        .task { viewModel.loadUser() }
    }
    
    private var profileHeader: some View {
        if let user = viewModel.user {
            return AnyView(
                Button(action: { navManager.navigateTo(.profile) }) {
                    HStack {
                        ProfilePhotoView(imageUrl: user.profilePhotoUrl)
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
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var commonOptions: some View {
        Group {
            Button(action: { navManager.navigateTo(.settings) }) {
                Label("Settings", systemImage: "gear")
            }
            
            Button(action: { navManager.navigateTo(.support) }) {
                Label("Support", systemImage: "questionmark.circle")
            }
        }
    }
    
    private var roleSpecificOptions: some View {
        Group {
            if viewModel.user?.role == .serviceSeeker {
                Button(action: { navManager.navigateTo(.becomeProvider) }) {
                    Label("Become Provider", systemImage: "arrowshape.up")
                }
            }
            
            if viewModel.user?.role == .serviceProvider {
                Button(action: { navManager.navigateTo(.manageServices) }) {
                    Label("Manage Services", systemImage: "briefcase")
                }
            }
        }
    }
    
    private var logoutOption: some View {
        Button(role: .destructive) {
            AuthService().logout()
            navManager.resetAllNavigation()
            print("logout tapped")
        } label: {
            Label("Log Out", systemImage: "door.left.hand.open")
        }
    }
}
