//
//  SmallBorderlessButonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

enum SmallBorderlessButtonStatus {
    case normal, disabled
}

struct SmallBorderlessButtonStyle: ButtonStyle {
    var status: SmallBorderlessButtonStatus
    
    init(status: SmallBorderlessButtonStatus = .normal) {
        self.status = status
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let foregroundColor: Color
        
        switch status {
        case .normal: foregroundColor = Color.accentColor
        case .disabled: foregroundColor = Color.gray15
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
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
