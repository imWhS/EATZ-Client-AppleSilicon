//
//  VerticalAlignedButtonView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/17/25.
//

import SwiftUI

struct VerticalAlignedButtonView: View {
    
    let image: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(image)
                    .frame(width: 22, height: 22)
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.accentColor)
            }
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressedButtonBackgroundStyle())
        .contentShape(Rectangle())
    }
    
}

#Preview {
    VerticalAlignedButtonView(image: "like", title: "좋아요 목록에 추가") {
        print("hello")
    }
}
