//
//  CountryModel.swift
//  Servx
//
//  Created by Makhlug Jafarov on 19/07/2024.
//

import Foundation
import SwiftUI

struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
}
