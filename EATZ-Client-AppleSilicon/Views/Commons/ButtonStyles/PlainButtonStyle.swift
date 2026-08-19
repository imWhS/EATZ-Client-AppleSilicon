//
//  PlainButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct PlainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.accentColor)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
