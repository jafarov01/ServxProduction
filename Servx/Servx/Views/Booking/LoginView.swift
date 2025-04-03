//
//  LoginView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 04. 04..
//


struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    @EnvironmentObject private var navigationManager: NavigationManager

    // Dependency Injection for ViewModel
    init(viewModel: LoginViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {