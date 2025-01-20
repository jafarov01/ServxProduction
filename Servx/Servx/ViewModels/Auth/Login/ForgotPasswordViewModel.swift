//
//  ForgotPasswordViewModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 2025. 01. 13..
//

import SwiftUI

class ForgotPasswordViewModel : ObservableObject {
    
    @Published var email: String = ""
    
    var isFormValid = true;
    
    func forgotPassword() {
        print("email sent");
    }
}
