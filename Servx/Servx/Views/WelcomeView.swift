//
//  WelcomeView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()
    
    var body: some View {
        VStack {
            ServxTextView(text: "Welcome", color: .white, size: 50, weight: .bold, alignment: .leading)
                .padding(.trailing, 100)
                .padding(.top, 50)
                .padding(.bottom, 40)
            
            ServxTextView(text: "Please, enter your mobile number. You will receive an OTP code in order to continue with registration.", color: .white, size: 20, weight: .light, alignment: .leading)
            
            VStack(spacing: 16) {
                Picker("Select your country", selection: $viewModel.selectedCountry) {
                    ForEach(viewModel.countries) { country in
                        Text("\(country.name) (\(country.code))").tag(country as Country?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .foregroundColor(.black)
                .frame(width: 300, height: 100, alignment: .center)
                
                TextField("Mobile Number", text: $viewModel.mobileNumber)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .keyboardType(.numberPad)
                
                if let error = viewModel.mobileNumberError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            
            Spacer()
            
            ServxButtonView(
                title: "Continue",
                width: UIScreen.main.bounds.width - 64,
                height: 50,
                frameColor: .white,
                innerColor: viewModel.isFormValid ? .white : .gray,
                textColor: Color("primary600"),
                action: {
                    viewModel.continueAction()
                }
            )
            .disabled(!viewModel.isFormValid)
            .padding(.bottom, 40)
        }
        .background(Color("primary300"))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    WelcomeView()
}
