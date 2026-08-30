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
        .cornerRadius(14)
        .padding(.horizontal, 20)
    }
}
