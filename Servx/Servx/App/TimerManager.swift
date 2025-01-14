//
//  TimerManager.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import Foundation
import SwiftUI

class TimerManager: ObservableObject {
    @Published var remainingSeconds: Int = 0
    private var timer: Timer?
    
    func startTimer(seconds: Int) {
        remainingSeconds = seconds
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.timer?.invalidate()
            }
        }
    }
}
