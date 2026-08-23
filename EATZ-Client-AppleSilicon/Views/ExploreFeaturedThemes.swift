//
//  ThemeComponents.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/19/25.
//

import SwiftUI

enum FeaturedThemesState {
    case loading
    case loaded(themes: [Theme])
    case error(message: String)
}

struct ExploreFeaturedThemes: View {
    let featuredThemesState: FeaturedThemesState
    let pagedAllThemes: Paged<TagTheme>
    let loadMore: () -> Void
    let onThemeTapped: (TagTheme) -> Void
    let onRetryTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ThemeFeaturedSection(
                state: featuredThemesState,
                onThemeTapped: onThemeTapped,
                onRetryTapped: onRetryTapped)
            HorizontalDivider()
            ThemeAllSection(
                pagedThemes: pagedAllThemes,
                onThemeTapped: onThemeTapped,
                loadNextPageAction: loadMore,
                onRetryTapped: onRetryTapped)
        }
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
    let onThemeTapped: (TagTheme) -> Void
    let loadNextPageAction: () -> Void
    let onRetryTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if pagedThemes.totalElements == 0 {
                EmptyView()
            } else {
                ThemeSectionHeader(title: "모든 테마")
                
                Group {
                    if !(pagedThemes.isEmpty) {
                        ThemeList(
                            themes: pagedThemes.items,
                            onItemTapped: onThemeTapped,
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
                .padding(.vertical, 10)
            }
        }
        .padding(.vertical, 10)
    }
}

struct ThemeFeaturedSection: View {
    let state: FeaturedThemesState
    let onThemeTapped: (TagTheme) -> Void
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
                    ThemeFeaturedCarousel(theme: theme, onItemTapped: onThemeTapped)
                }
            }
            .padding(.vertical, 10)
        } else { EmptyView() }
    }
}
