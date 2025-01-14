//
//  OTPInputView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import SwiftUI

struct OTPInputView: View {
    @StateObject private var viewModel = SendOTPViewModel()
    let numberOfFields: Int
    
    @State private var enteredOTP: [String]
    @FocusState private var focusedField: Int?

    init(numberOfFields: Int) {
        self.numberOfFields = numberOfFields
        self._enteredOTP = State(initialValue: Array(repeating: "", count: numberOfFields))
    }

    var body: some View {
        otpFields
            .onChange(of: enteredOTP) { oldValue, newValue in
                handleOTPChange(newValue: newValue)
            }
    }

    private var otpFields: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfFields, id: \.self) { index in
                otpField(for: index)
            }
        }
    }

    private func otpField(for index: Int) -> some View {
        TextField("", text: $enteredOTP[index])
            .keyboardType(.numberPad)
            .frame(width: 48, height: 48)
            .background(Color.yellow.opacity(0.2)) // Subtle yellow for better aesthetics
            .cornerRadius(8) // Increased corner radius for a smoother look
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: index)
            .onChange(of: enteredOTP[index]) { oldValue, newValue in
                handleTextChange(newValue: newValue, index: index)
            }
    }

    private func handleTextChange(newValue: String, index: Int) {
        if newValue.count > 1 {
            enteredOTP[index] = String(newValue.prefix(1))
        } else if newValue.isEmpty {
            if index > 0 {
                focusedField = index - 1
            }
        } else {
            if index < numberOfFields - 1 {
                focusedField = index + 1
            } else {
                focusedField = nil
            }
        }
    }

    private func handleOTPChange(newValue: [String]) {
        viewModel.enteredOTP = newValue.joined()
    }
}

struct OTPInputView_Previews: PreviewProvider {
    static var previews: some View {
        OTPInputView(numberOfFields: 4)
    }
}
