//
//  SmallRoundedButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

enum SmallRoundedButtonType {
    case primary, secondary, danger, disabled
}

struct SmallRoundedButtonStyle: ButtonStyle {
    var type: SmallRoundedButtonType
    var isIconOnly: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color
        let foregroundColor: Color
        
        switch type {
        case .primary:
            backgroundColor = .accentColor
            foregroundColor = .white
        case .secondary:
            backgroundColor = Color.buttonSecondary
            foregroundColor = .accentColor
        case .danger:
            backgroundColor = Color.buttonSecondary
            foregroundColor = .red
        case .disabled:
            backgroundColor = Color.gray2
            foregroundColor = Color.gray15
        }
        
        @ViewBuilder
        var content: some View {
            if isIconOnly {
                configuration.label
                    .frame(width: 32, height: 32)
            } else {
                configuration.label
                    .font(Font.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 14)
                    .frame(height: 32)
            }
        }
        
        return content
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(16)
            .scaleEffect(type != .disabled && configuration.isPressed ? 0.965 : 1.0)
            .opacity(type != .disabled && configuration.isPressed ? 0.5 : 1.0)
            .animation(
                configuration.isPressed ? .easeInOut(duration: 0.1) : .easeInOut(duration: 0.25),
                value: configuration.isPressed
            )
            .opacity(type == .disabled ? 0.5 : 1)
            .disabled(type == .disabled)
    }
}
