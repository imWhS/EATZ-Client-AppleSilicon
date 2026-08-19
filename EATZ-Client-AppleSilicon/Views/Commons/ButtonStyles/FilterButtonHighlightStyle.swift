//
//  FilterButtonHighlightStyle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct FilterButtonHighlightStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.buttonSecondary.opacity(configuration.isPressed ? 1 : 0)
            )
            .cornerRadius(18)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
