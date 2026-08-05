//
//  BigRoundedButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct TodaySearchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .font(Font.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 68, height: 68)
            .background(Color.accentColor)
            .cornerRadius(37)
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(
                configuration.isPressed ? .easeInOut(duration: 0.1) : .easeInOut(duration: 0.25),
                value: configuration.isPressed
            )
    }
    
}
