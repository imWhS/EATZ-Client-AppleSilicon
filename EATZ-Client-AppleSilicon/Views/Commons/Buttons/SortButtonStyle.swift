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
                configuration.isPressed ? .easeInOut(duration: 0.1) : .easeInOut(duration: 0.25),
                value: configuration.isPressed
            )
    }
}
