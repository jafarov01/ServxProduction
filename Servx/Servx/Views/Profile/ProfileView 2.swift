//
//  ProfileView 2.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 09..
//


struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showPhotoEditor = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Profile Photo
                ProfilePhotoView(imageUrl: viewModel.user?.profileImageUrl)
                    .frame(width: 120, height: 120)
                    .overlay( // Camera icon overlay to indicate editability
                        Group {
                            if viewModel.user != nil {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .padding([.bottom, .trailing], 4)
                            }
                        },
                        alignment: .bottomTrailing
                    )
                    .onTapGesture {
                        if viewModel.user != nil {
                            showPhotoEditor = true
                        }
                    }

                // Profile Info
                if let user = viewModel.user {
                    Text(user.name)
                        .font(.title2).bold()
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let addr = user.address {
                        Text("\(addr.street), \(addr.city)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Loading and Error States
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                    Button("Retry") {
                        viewModel.loadProfile()
                    }
                    .padding(.top, 4)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showPhotoEditor) {
            // Use the same view model in the edit view for shared state
            ProfilePhotoEditView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
}
