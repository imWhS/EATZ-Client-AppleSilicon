//
//  SmallBorderlessButonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct SmallBorderlessButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 14, weight: .bold))
            .foregroundColor(.accentColor)
            .frame(height: 22)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(configuration.isPressed ? Color.init("ECECEC") : .clear)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .cornerRadius(12)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
    
}
