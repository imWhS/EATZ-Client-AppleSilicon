//
//  VerticalAlignedButtonView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/17/25.
//

import SwiftUI

struct VerticalAlignedButton: View {
    let image: String
    let title: String
    let verticalPadding: CGFloat
    let highlightCornerRadius: CGFloat
    let action: () -> Void

    init(image: String, title: String, verticalPadding: CGFloat = 10, highlightCornerRadius: CGFloat = 12, action: @escaping () -> Void) {
        self.image = image
        self.title = title
        self.verticalPadding = verticalPadding
        self.highlightCornerRadius = highlightCornerRadius
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(image)
                    .frame(width: 22, height: 22)
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SquareHighlightButtonStyle(cornerRadius: highlightCornerRadius))
        .contentShape(Rectangle())
    }
    
}

#Preview {
    VerticalAlignedButton(image: "like", title: "좋아요 목록에 추가") {
        print("hello")
    }
}
