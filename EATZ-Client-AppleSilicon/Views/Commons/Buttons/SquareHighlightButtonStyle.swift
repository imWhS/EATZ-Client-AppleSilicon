//
//  SquareHighlightButtonStyle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/26/25.
//

import SwiftUI

struct SquareHighlightButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        @ViewBuilder
        var content: some View {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isPressed ? Color.init(hex: "ECECEC") : Color.clear)
                )
                .cornerRadius(isPressed ? cornerRadius : 0)
                .contentShape(Rectangle())
                .scaleEffect(isPressed ? 0.965 : 1.0)
                .opacity(isPressed ? 0.5 : 1.0)
                .animation(
                    isPressed ? .easeInOut(duration: 0.1) : .easeInOut(duration: 0.25),
                    value: isPressed
                )
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
