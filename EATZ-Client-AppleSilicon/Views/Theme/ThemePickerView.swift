//
//  ThemePickerView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import SwiftUI

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = ThemePickerViewModel()
    
    let onComplete: (Int64?) -> Void
    
    var body: some View {
        mainContent
            .task { viewModel.resetAndLoadAll() }
    }
    
    private var mainContent: some View {
        NavigationStack {
            VStack(spacing: 0) {
                themesSection
                bottomSection
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissToolbarItem
                titleToolbarItem
            }
            .toolbarBackground(viewModel.showNavigationBarTitle ? .visible : .hidden, for: .navigationBar)
        }
    }
    
    private var themesSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                scrollTrackingGeometryReader
                themesSectionHeader
                ExploreThemes(
                    featuredThemesState: viewModel.featuredThemesState,
                    pagedAllThemes: viewModel.pagedThemes,
                    onLoadMoreAllThemes: viewModel.loadMoreAllThemes,
                    onSelect: { tagTheme in handleSelection(id: tagTheme.id) },
                    onRetry: viewModel.resetAndLoadAll)
            }
            .padding(.vertical, 20)
        }
        .background(Color.backgroundPrimary)
        .coordinateSpace(name: "scroll")
    }
    
    private var themesSectionHeader: some View {
        VStack(spacing: 8) {
            Text("테마")
                .font(.system(size: 30, weight: .bold))
            Text("원하는 주제의 태그가 달린 레시피만 둘러볼 수 있어요.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray35)
        }
        .padding(.vertical, 20)
    }
    
    private var bottomSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                handleSelection(id: nil)
            }) {
                Text("설정 안 함").frame(maxWidth: .infinity)
            }
            .buttonStyle(CapsuleLargeButtonStyle(appearance: .secondary))
            .padding(.horizontal, 20)
            Text("모든 레시피를 둘러봅니다.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray35)
        }
        .padding(.vertical, 20)
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("테마")
                .font(.headline)
                .opacity(viewModel.showNavigationBarTitle ? 1 : 0)
        }
    }
    
    private var scrollTrackingGeometryReader: some View {
        GeometryReader { proxy in
            let scrollYOffset = proxy.frame(in: .named("scroll")).minY
            Color.clear
                .onChange(of: scrollYOffset) { _, scrollYOffset in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showNavigationBarTitle = scrollYOffset < -100
                    }
                }
        }
        .frame(height: 0)
    }
    
    private func handleSelection(id: Int64?) {
        onComplete(id)
        dismiss()
    }
}
