//
//  RoundedButtonAppearance.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/29/26.
//

import SwiftUI

enum RoundedButtonAppearance {
    case primary
    case authPrimary
    case secondary
    case authSecondary
    case danger
    case disabled
    
    var foregroundColor: Color {
        switch self {
        case .primary: .white
        case .authPrimary: .white
        case .secondary: .accentColor
        case .authSecondary: .auth
        case .danger: .red
        case .disabled: .gray25
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .primary: .accentColor
        case .authPrimary: .auth
        case .secondary: .buttonSecondary
        case .authSecondary: .buttonSecondary
        case .danger: .buttonSecondary
        case .disabled: .buttonSecondary
        }
    }
}
