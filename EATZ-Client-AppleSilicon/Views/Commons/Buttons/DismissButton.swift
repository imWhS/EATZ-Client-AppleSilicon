//
//  DismissButton.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/10/25.
//

import SwiftUI

struct DismissButton: View {
    
    var action: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image("dismiss")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
        }
        .frame(width: 32, height: 32)
        .background(Color.init("ECECEC"))
        .clipShape(Circle())
        .buttonStyle(PlainButtonStyle())
        .opacity(isPressed ? 0.4 : 1)
        .animation(.easeOut(duration: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
}

#Preview {
    DismissButton() {
        print("Dismiss")
    }
}
