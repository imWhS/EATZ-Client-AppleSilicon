//
//  CapsuleLargeButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

enum CapsuleLargeButtonAppearance {
    case primary
    case authPrimary
    case secondary
    case authSecondary
    case disabled
}

struct CapsuleLargeButtonStyle: ButtonStyle {
    var appearance: CapsuleLargeButtonAppearance
    
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color
        let foregroundColor: Color
        
        switch appearance {
        case .primary:
            backgroundColor = .accentColor
            foregroundColor = .white
        case .authPrimary:
            backgroundColor = .auth
            foregroundColor = .white
        case .secondary:
            backgroundColor = Color.buttonSecondary
            foregroundColor = .accentColor
        case .authSecondary:
            backgroundColor = Color.buttonSecondary
            foregroundColor = .auth
        case .disabled:
            backgroundColor = Color.buttonSecondary
            foregroundColor = .accentColor
        }
        
        return configuration.label
            .font(Font.system(size: 17, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .frame(height: 42)
            .padding(.horizontal, 18)
            .background(backgroundColor)
            .cornerRadius(12)
            .scaleEffect(appearance != .disabled && configuration.isPressed ? 0.95 : 1.0)
            .opacity(appearance != .disabled && configuration.isPressed ? 0.5 : 1.0)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .disabled(appearance == .disabled)
    }
}
