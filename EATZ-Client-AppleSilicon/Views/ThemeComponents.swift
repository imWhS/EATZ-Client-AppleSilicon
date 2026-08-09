//
//  ThemeComponents.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/19/25.
//

import SwiftUI

enum TagThemesFeaturedState {
    case loading
    case loaded(themes: [Theme])
    case error(message: String)
}

struct ExploreThemes: View {
    let featuredThemesState: TagThemesFeaturedState
    let pagedAllThemes: Paged<TagTheme>
    let loadMore: () -> Void
    let onItemTapped: (TagTheme) -> Void
    let onRetryTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ThemeFeaturedSection(
                state: featuredThemesState,
                onItemTapped: onItemTapped,
                onRetryTapped: onRetryTapped)
            ThemeAllSection(
                pagedThemes: pagedAllThemes,
                onSelect: onItemTapped,
                loadNextPageAction: loadMore,
                onRetryTapped: onRetryTapped)
        }
        .padding(.vertical, 10)
    }
}

struct ThemeSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}

struct ThemeAllSection: View {
    let pagedThemes: Paged<TagTheme>
    let onSelect: (TagTheme) -> Void
    let loadNextPageAction: () -> Void
    let onRetryTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            if pagedThemes.totalElements == 0 {
                EmptyView()
            } else {
                ThemeSectionHeader(title: "모든 테마")
                
                if !(pagedThemes.isEmpty) {
                    ThemeList(
                        themes: pagedThemes.items,
                        onItemTapped: onSelect,
                        hasNextPage: pagedThemes.hasNextPage,
                        isLoadingNextPage: pagedThemes.isLoadingNextPage,
                        loadNextPageAction: loadNextPageAction)
                } else if let errorMessage = pagedThemes.errorMessage {
                    ErrorCurtain(errorMessage, onRetryTapped: onRetryTapped)
                } else if pagedThemes.isLoadingNextPage {
                    LoadingCurtain(title: "모든 테마를 불러오고 있어요...")
                } else {
                    CommonEmptyStateView(title: "보여드릴 테마가 없어요.")
                    Curtain(
                        title: "보여드릴 테마가 없어요.",
                        header: {
                            Image("info-200")
                                .resizable()
                                .foregroundStyle(Color.gray15)
                                .frame(width: 40, height: 40)
                        }
                    )
                }
            }
        }
    }
}

struct ThemeFeaturedSection: View {
    let state: TagThemesFeaturedState
    let onItemTapped: (TagTheme) -> Void
    let onRetryTapped: () -> Void
    
    var body: some View {
        switch state {
        case .loading: LoadingCurtain(title: "카테고리 별 테마를 불러오고 있어요...")
        case .loaded(let themes): featuredList(themes: themes)
        case .error(let message): ErrorCurtain(message, onRetryTapped: onRetryTapped)
        }
    }
    
    @ViewBuilder
    private func featuredList(themes: [Theme]) -> some View {
        if !themes.isEmpty {
            VStack(spacing: 0) {
                ThemeSectionHeader(title: "카테고리")
                ForEach(themes) { theme in
                    ThemeFeaturedCarousel(theme: theme, onItemTapped: onItemTapped)
                }
            }
        } else { EmptyView() }
    }
}
