//
//  RoundedButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    var appearance: RoundedButtonAppearance
    var size: RoundedButtonSize
    
    init(_ appearance: RoundedButtonAppearance, _ size: RoundedButtonSize) {
        self.appearance = appearance
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .font(size.font)
            .foregroundStyle(appearance.foregroundColor)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(appearance.backgroundColor)
            .cornerRadius(size.cornerRadius)
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
