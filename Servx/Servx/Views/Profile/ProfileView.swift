//
//  BookingView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//


import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @EnvironmentObject private var navManager: NavigationManager
    
    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack {
                    ProfilePhotoView(imageUrl: URL(string: viewModel.user?.profilePhotoUrl ?? ""))
                        .frame(width: 140, height: 140)
                        .onTapGesture {
                            navManager.navigateTo(.edit)
                        }
                    
                    Text("\(viewModel.user?.firstName ?? "") \(viewModel.user?.lastName ?? "")")
                        .font(.title)
                        .padding(.top, 8)
                }
                .padding(.top, 20)
                
                // Options List
                VStack(spacing: 0) {
                    Divider()
                    
                    optionRow(title: "Profile")
                    Divider()
                    optionRow(title: "Settings") { navManager.navigateTo(.settings) }
                    Divider()
                    optionRow(title: "Support") { navManager.navigateTo(.support) }
                    Divider()
                    optionRow(title: "Log out", color: .red) { print("Logout tapped") }
                    Divider()
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    navManager.navigateTo(.edit)
                }
            }
        }
        .onAppear {
            viewModel.loadUserProfile()
        }
    }
    
    // Reusable option row component
    private func optionRow(title: String, color: Color = .primary, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(color)
                Spacer()
            }
            .padding()
            .contentShape(Rectangle()) // Makes entire row tappable
        }
    }
}
