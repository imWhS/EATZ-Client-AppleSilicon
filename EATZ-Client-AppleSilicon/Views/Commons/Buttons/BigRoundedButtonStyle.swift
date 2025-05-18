//
//  BigRoundedButtonStyle.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct BigRoundedButtonStyle: ButtonStyle {
    
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
            .font(Font.system(size: 16, weight: .bold))
            .foregroundColor(foregroundColor)
            .frame(height: 42)
            .padding(.horizontal, 18)
            .background(backgroundColor)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
    
}
