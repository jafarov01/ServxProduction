//
//  SendOTPViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import Foundation

class SendOTPViewModel: ObservableObject {
    @Published var enteredOTP: String = ""

    func verifyOTP(completion: @escaping (Bool) -> Void) {
        // Simulate OTP verification logic
        // Replace with actual verification logic
        let isMatching = enteredOTP == "1234" // Example condition
        completion(isMatching)
    }
}
