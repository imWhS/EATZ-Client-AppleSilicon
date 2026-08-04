//
//  FilterButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/12/25.
//

import SwiftUI

struct FilterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 14, weight: .semibold))
            .foregroundStyle(.black)
            .frame(height: 30)
            .padding(.horizontal, 10)
            .background(configuration.isPressed ? Color.buttonSecondary : Color.buttonSecondary)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .cornerRadius(14)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
