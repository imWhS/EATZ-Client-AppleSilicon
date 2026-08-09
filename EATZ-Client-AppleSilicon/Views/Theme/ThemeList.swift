//
//  ThemeList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import SwiftUI

struct ThemeList: View {
    let themes: [TagTheme]
    let onItemTapped: (TagTheme) -> Void
    let hasNextPage: Bool
    let isLoadingNextPage: Bool
    let loadNextPageAction: () -> Void
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(themes) { theme in
                ThemeItem(theme, theme.id != themes.last!.id, { onItemTapped(theme) })
            }
            HorizontalDivider()
            ListPageTailView(hasNextPage: hasNextPage, onAppear: loadNextPageAction)
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
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
    
    ScrollView {
        VStack(spacing: 0) {
            ThemeList(themes: tags, onItemTapped: { _ in }, hasNextPage: true, isLoadingNextPage: true, loadNextPageAction: { } )
        }
    }
    .background(Color.gray)
}
