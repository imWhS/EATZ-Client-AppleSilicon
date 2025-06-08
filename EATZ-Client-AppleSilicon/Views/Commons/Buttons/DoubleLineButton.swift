//
//  DoubleLineButton.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/19/25.
//

import SwiftUI

struct DoubleLineButton: View {
    
    let firstIcon: String?
    
    let firstTitle: String
    
    let secondTitle: String
    
    let isShowArrow: Bool
    
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(firstIcon: String? = nil, firstTitle: String, secondTitle: String, isShowArrow: Bool = false, isShowDivider: Bool = false, action: @escaping () -> Void) {
        self.firstIcon = firstIcon
        self.firstTitle = firstTitle
        self.secondTitle = secondTitle
        self.isShowArrow = isShowArrow
        self.action = action
    }
    
    var body: some View {
        Button(action: {
                    action()
        }) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        if let firstIcon = firstIcon {
                            Image(firstIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 16)
                                .foregroundStyle(Color.black)
                        }
                        Text(firstTitle)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(secondTitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.init("BEBEB9"))
                }
                
                Spacer()
                
                if isShowArrow {
                    ZStack(alignment: .center) {
                        Circle()
                            .foregroundStyle(Color.init("ECECEC"))
                        
                            Image("arrow-down-button")
                                .foregroundStyle(Color.accentColor)
                                .offset(x: 0.25, y: 0.5)
                    }
                    .frame(width: 18, height: 18)
                }
            }            .contentShape(Rectangle())
            .opacity(isPressed ? 0.5 : 1.0)
            .animation(isPressed ? .easeIn(duration: 0.075) : .easeOut(duration: 0.3), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
                )
        
    }
}

#Preview {
    DoubleLineButton(firstIcon: "recipe-rating", firstTitle: "3.5", secondTitle: "평가", isShowArrow: true, isShowDivider: true) {
        print("DoubleLineButton tapped!")
    }
}
