//
//  SquareHighlightButtonStyle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/26/25.
//

import SwiftUI

struct SquareHighlightButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 0.0
    let isDisabled: Bool
    
    init(cornerRadius: CGFloat = 0.0, isDisabled: Bool = false) {
        self.cornerRadius = cornerRadius
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        @ViewBuilder
        var content: some View {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isPressed ? Color.buttonSecondary : Color.clear)
                )
                .cornerRadius(isPressed ? cornerRadius : 0)
                .contentShape(Rectangle())
                .scaleEffect(isDisabled ? 1.0 : (configuration.isPressed ? 0.965 : 1.0))
                .opacity(isDisabled ? 1 : (configuration.isPressed ? 0.5 : 1.0))
                .animation(
                    configuration.isPressed
                        ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                        : .spring(response: 0.35, dampingFraction: 0.6),
                    value: configuration.isPressed
                )
                .disabled(isDisabled)
        }
        
        return content
    }
}

#Preview {
    VStack {
        Button(action: {}) {
            HStack {
                Text("버튼")
                Spacer()
                Text(">")
            }
            .padding(8)
        }
        .buttonStyle(SquareHighlightButtonStyle(cornerRadius: 12))
        
        Button(action: {}) {
            VStack {
                Text("버튼")
                Text("상세 정보")
            }
            .padding(20)
        }
        .buttonStyle(SquareHighlightButtonStyle(cornerRadius: 20))
        
    }
}
