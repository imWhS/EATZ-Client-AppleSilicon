//
//  ThemeFeaturedList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import SwiftUI

struct ThemeFeaturedList: View {
    let theme: Theme
    let onAction: (TagTheme) -> Void
    
    private var cellWidth: CGFloat {
        ((UIScreen.main.bounds.width) - rowSpacing - (horizontalPadding * 2)) / 2
    }
    private let rowSpacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 20
    
    let rows: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            tagNameText
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: rowSpacing) {
                    ForEach(theme.tags) { tag in
                        ThemeFeaturedItem(theme: tag, width: cellWidth, onAction: { onAction(tag) })
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var tagNameText: some View {
        Text(theme.name)
            .font(.system(size: 14))
            .foregroundStyle(Color.gray60)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, horizontalPadding)
    }
}

#Preview {
    let tags: [TagTheme] = [
        .init(id: 1, name: "한식", keyword: "", emoji: "🇰🇷", description: "", createdAt: .now, updatedAt: .now),
        .init(id: 2, name: "일식", keyword: "", emoji: "🇯🇵", description: "", createdAt: .now, updatedAt: .now),
        .init(id: 3, name: "중식", keyword: "", emoji: "🇨🇳", description: "", createdAt: .now, updatedAt: .now),
        .init(id: 4, name: "양식", keyword: "", emoji: "🍝", description: "", createdAt: .now, updatedAt: .now),
        .init(id: 5, name: "분식", keyword: "", emoji: "", description: "", createdAt: .now, updatedAt: .now)
    ]
    let theme: Theme = Theme(id: 1, name: "국가 별", description: "", tags: tags)
    ScrollView {
        VStack(spacing: 0) {
            ThemeFeaturedList(theme: theme, onAction: { _ in })
            ThemeFeaturedList(theme: theme, onAction: { _ in })
            ThemeFeaturedList(theme: theme, onAction: { _ in })
        }
    }
}
