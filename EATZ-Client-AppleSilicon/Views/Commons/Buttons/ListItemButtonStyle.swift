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
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.035 : 0.075),
                radius: configuration.isPressed ? 3 : 6,
                y: configuration.isPressed ? 1.5 : 3
            )
            .animation(
                configuration.isPressed ? .easeInOut(duration: 0.1) : .easeInOut(duration: 0.25),
                value: configuration.isPressed
            )
    }
}
