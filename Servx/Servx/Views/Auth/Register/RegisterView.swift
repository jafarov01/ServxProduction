//
//  RegisterView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2024. 11. 30..
//
import SwiftUI

struct RegisterView: View {
    @State var isCustomerOnly: Bool = true
    @StateObject private var viewModel: RegisterViewModel
    @EnvironmentObject private var navigationManager: NavigationManager

    init(viewModel: @autoclosure @escaping () -> RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        
        HStack {
            Button(action: {
                navigationManager.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .padding()
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .frame(height: 44)
        
        ScrollView {
            VStack(spacing: 10) {
                // Title
                ServxTextView(
                    text: "Create Profile",
                    color: Color("primary500"),
                    size: 32,
                    weight: .bold,
                    alignment: .center,
                    paddingValues: EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0),
                    lineSpacing: 4
                )

                // Role Selection Buttons
                HStack(spacing: 16) {
                    ServxButtonView(
                        title: "Customer",
                        width: 163,
                        height: 40,
                        frameColor: Color("primary500"),
                        innerColor: isCustomerOnly ? Color("primary500") : .white,
                        textColor: isCustomerOnly ? .white : Color("greyScale500"),
                        cornerRadius: 8,
                        action: { isCustomerOnly = true }
                    )

                    ServxButtonView(
                        title: "Service Provider",
                        width: 163,
                        height: 40,
                        frameColor: Color("primary500"),
                        innerColor: !isCustomerOnly ? Color("primary500") : .white,
                        textColor: !isCustomerOnly ? .white : Color("greyScale500"),
                        cornerRadius: 8,
                        action: { isCustomerOnly = false }
                    )
                }

//                // Dynamic Input View
//                if isCustomerOnly {
//                    ServiceSeekerRegistrationView(viewModel: viewModel)
//                } else {
//                    ServiceProviderRegistrationView(viewModel: viewModel)
//                }
                
                // Footer
                ServiceAuthView(hasAccount: false)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
