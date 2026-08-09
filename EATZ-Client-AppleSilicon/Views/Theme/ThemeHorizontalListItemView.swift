//
//  ThemeFeaturedItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import SwiftUI

struct ThemeFeaturedItem: View {
    let theme: TagTheme
    let width: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button (action: action) {
            VStack(alignment: .leading, spacing: 4) {
                if let emoji = theme.emoji, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 24, weight: .semibold))
                } else {
                    Text(String(theme.name.prefix(1)))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.gray20)
                }
                Text(theme.name)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .foregroundStyle(Color.black)
            }
            .padding(.horizontal, 14)
            .frame(width: width, height: 74)
            .background(Color.buttonSecondary)
        }
        .buttonStyle(ScaleDownButtonStyle(cornerRadius: 12))
    }
}

#Preview {
    ThemeFeaturedItem(
        theme: TagTheme(
            id: 0,
            name: "한식",
            keyword: "",
            emoji: "🇰🇷",
            description: "",
            createdAt: .now,
            updatedAt: .now),
        width: 120,
        action: {print("item tapped!")}
    )
}
