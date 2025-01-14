//
//  OtpView.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import Foundation
import SwiftUI

struct SendOTPView: View {
    @StateObject var timerManager = TimerManager()
    @StateObject var viewModel = SendOTPViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with Image
            HStack(spacing: 8) {
                ServxTextView(
                    text: "You've got email",
                    color: Color("primary500"),
                    size: 24,
                    weight: .bold,
                    alignment: .center
                )
                Image("authEmailImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }

            // Instructional Text
            ServxTextView(
                text: "We have sent the OTP verification code to your email address. Check your email and enter the code below.",
                color: .gray,
                size: 16,
                weight: .bold,
                alignment: .center,
                paddingValues: EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16),
                lineSpacing: 4
            )

            // Countdown Button
            ServxButtonView(
                title: "Start Countdown",
                width: 200,
                height: 44,
                frameColor: .clear,
                innerColor: Color("primary500"),
                textColor: .white,
                font: .body,
                cornerRadius: 10,
                action: {
                    timerManager.startTimer(seconds: 60)
                }
            )

            // OTP Input Fields
            OTPInputView(numberOfFields: 4)

            // Text for Missing Email
            ServxTextView(
                text: "Didn't receive email?",
                color: .gray,
                size: 12,
                weight: .bold,
                alignment: .center,
                paddingValues: EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)
            )

            // Resend Countdown Text
            ServxTextView(
                text: "You can resend code in \(timerManager.remainingSeconds)",
                color: .gray,
                size: 14,
                weight: .bold,
                alignment: .center,
                paddingValues: EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
            )

            // Continue Button
            ServxButtonView(
                title: "Continue",
                width: 342,
                height: 56,
                frameColor: Color("primary500"),
                innerColor: Color("primary500"),
                textColor: .white,
                font: .headline,
                cornerRadius: 12,
                action: {
                    viewModel.verifyOTP { isMatching in
                        if isMatching {
                            print("MEX all good OTP matches")
                        } else {
                            print("MEX OTP does not match :)")
                        }
                    }
                }
            )
        }
        .padding(16)
    }
}

#Preview {
    SendOTPView()
}
