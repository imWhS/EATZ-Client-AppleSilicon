//
//  RoundedMediumButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct RoundedMediumButtonStyle: ButtonStyle {
    var appearance: RoundedButtonAppearance
    var isIconOnly: Bool = false
    
    @ScaledMetric(relativeTo: .subheadline) private var iconSize: CGFloat = 32
    
    func makeBody(configuration: Configuration) -> some View {
        @ViewBuilder
        var content: some View {
            if isIconOnly {
                configuration.label
                    .frame(width: iconSize, height: iconSize)
            } else {
                configuration.label
                    .font(Font.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }
        }
        
        return content
            .foregroundStyle(appearance.foregroundColor)
            .background(appearance.backgroundColor)
            .cornerRadius(16)
            .scaleEffect(appearance != .disabled && configuration.isPressed ? 0.95 : 1.0)
            .opacity(appearance != .disabled && configuration.isPressed ? 0.5 : 1.0)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .opacity(appearance == .disabled ? 0.5 : 1)
            .disabled(appearance == .disabled)
    }
}
