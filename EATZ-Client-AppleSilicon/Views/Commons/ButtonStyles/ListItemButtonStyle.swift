//
//  ListItemButtonStyle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/16/25.
//

import SwiftUI

struct ListItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.035 : 0.075),
                radius: configuration.isPressed ? 3 : 6,
                y: configuration.isPressed ? 1.5 : 3
            )
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
