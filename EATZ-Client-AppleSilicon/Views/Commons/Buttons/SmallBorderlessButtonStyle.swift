//
//  SmallBorderlessButonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

enum SmallBorderlessButtonType {
    case normal, disabled
}

struct SmallBorderlessButtonStyle: ButtonStyle {
    var type: SmallBorderlessButtonType
    
    init(type: SmallBorderlessButtonType = .normal) {
        self.type = type
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let foregroundColor: Color
        
        switch type {
        case .normal:
            foregroundColor = Color.accentColor
        case .disabled:
            foregroundColor = Color.gray15
        }
        
        return configuration.label
            .font(Font.system(size: 14, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(configuration.isPressed ? Color.buttonSecondary : .clear)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(
                configuration.isPressed ? .easeInOut(duration: 0.1) : .easeInOut(duration: 0.25),
                value: configuration.isPressed
            )
        
    }
}
