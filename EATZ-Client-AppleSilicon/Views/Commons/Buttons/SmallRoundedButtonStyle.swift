//
//  SmallRoundedButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct SmallRoundedButtonStyle: ButtonStyle {
    
    enum ButtonType {
            case primary  // 글씨 흰색, 배경 accent
            case secondary  // 글씨 accent, 배경 연한 회색
    }
    
    var type: ButtonType
    
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color
        let foregroundColor: Color
        
        switch type {
        case .primary:
            backgroundColor = .accentColor
            foregroundColor = .white
        case .secondary:
            backgroundColor = Color.init("ECECEC")
            foregroundColor = .accentColor
        }
        
        return configuration.label
            .font(Font.system(size: 13.5, weight: .bold))
            .foregroundColor(foregroundColor)
            .frame(height: 32)
            .padding(.horizontal, 14)
            .background(backgroundColor)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
    
}
