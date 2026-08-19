//
//  HeaderIconButton.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct HeaderIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 13.5, weight: .semibold))
            .foregroundStyle(.white)
            .frame(height: 28)
            .padding(.horizontal, 14)
            .background(Color.accentColor)
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
