//
//  ScaleDownButtonStyle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/6/25.
//

import SwiftUI

struct ScaleDownButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let isDisabled: Bool
    
    init(cornerRadius: CGFloat = 0.0, isDisabled: Bool = false) {
        self.cornerRadius = cornerRadius
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(isDisabled ? 1.0 : (configuration.isPressed ? 0.965 : 1.0))
            .opacity(isDisabled ? 1 : (configuration.isPressed ? 0.5 : 1.0))
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .disabled(isDisabled)
    }
}
