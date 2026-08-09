//
//  ThemeItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import SwiftUI

private struct PressedListItemStyle: ButtonStyle {
    let defaultColor: Color
    let pressedColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedColor : defaultColor)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(configuration.isPressed ? .easeIn(duration: 0.1) : .easeOut(duration: 0.3), value: configuration.isPressed)
    }
}

struct ThemeItem: View {
    let theme: TagTheme
    let showDivider: Bool
    let action: () -> Void
    
    init(_ theme: TagTheme, _ showDivider: Bool = true, _ action: @escaping () -> Void) {
        self.theme = theme
        self.showDivider = showDivider
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button (action: action) {
                HStack(alignment: .center, spacing: 12) {
                    emojiView
                    themeNameText
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressedListItemStyle(defaultColor: Color.clear, pressedColor: Color.buttonSecondary))
            if showDivider {
                HorizontalDivider(padding: 0).padding(.leading, 16 + 26 + 12)
            }
        }
    }
    
    private var emojiView: some View {
        Group {
            if let emoji = theme.emoji, !emoji.isEmpty {
                Text(emoji)
            } else {
                Text(String(theme.name.prefix(1)))
                    .foregroundStyle(Color.gray20)
            }
        }
        .font(.system(size: 24, weight: .semibold))
        .frame(width: 26)
    }
    
    private var themeNameText: some View {
        Text(theme.name)
            .font(.system(size: 17, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .foregroundStyle(Color.black)
            .padding(.vertical, 14)
    }
}
