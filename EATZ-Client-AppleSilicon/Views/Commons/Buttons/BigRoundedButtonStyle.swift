//
//  BigRoundedButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

enum BigRoundedButtonType {
    case primary  // 글씨 흰색, 배경 accent
    case secondary  // 글씨 accent, 배경 연한 회색
    case disabled
}

struct BigRoundedButtonStyle: ButtonStyle {
    var type: BigRoundedButtonType
    
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color
        let foregroundColor: Color
        
        switch type {
        case .primary:
            backgroundColor = .accentColor
            foregroundColor = .white
        case .secondary:
            backgroundColor = Color.init(hex: "ECECEC")
            foregroundColor = .accentColor
        case .disabled:
            backgroundColor = Color.init(hex: "ECECEC")
            foregroundColor = .accentColor
        }
        
        return configuration.label
            .font(Font.system(size: 17, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .frame(height: 42)
            .padding(.horizontal, 18)
            .background(backgroundColor)
            .cornerRadius(12)
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
