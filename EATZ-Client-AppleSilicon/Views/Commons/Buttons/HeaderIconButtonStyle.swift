//
//  HeaderIconButton.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct HeaderIconButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 13.5, weight: .bold))
            .foregroundColor(.white)
            .frame(height: 28)
            .padding(.horizontal, 14)
            .background(Color.accentColor)
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
