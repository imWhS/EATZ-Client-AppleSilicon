//
//  SortButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/12/25.
//

import SwiftUI

struct SortButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.accentColor)
            .frame(height: 30)
            .padding(.horizontal, 10)
            .background(configuration.isPressed ? Color.buttonSecondary : .clear)
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
