//
//  ExploreSearchBar.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/7/25.
//

import SwiftUI

struct ExploreSearchBar: View {
    @Binding var keyword: String
    @Binding var isSearchMode: Bool
    @FocusState var isFocused: Bool
    
    let theme: ExploreTagItem?
    let onShowThemePicker: () -> Void
    
    var themeNameLabel: String {
        guard let theme = theme, let name = theme.name else { return "모든 레시피" }
        return name
    }
    
    var body: some View {
        HStack(spacing: 0) {
            leadingView
            trailingView
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchMode)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
        .frame(maxHeight: 66)
        .background(Color.white)
        .cornerRadius(33)
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 2)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .onChange(of: isFocused) { _, isFocused in
            /// isFocused가 `true`인 경우에만 검색 모드로 전환합니다.
            /// 다른 뷰가 push되는 등의 이유로 isFocused가 `false`가 되더라도, 검색 모드를 해제하지 않도록 처리합니다.
            if isFocused { self.isSearchMode = isFocused }
        }
    }
    
    private var leadingView: some View {
        HStack(spacing: 8) {
            Image("search-18")
                .padding(.leading, 20)
            VStack(alignment: .leading, spacing: 2) {
                ZStack(alignment: .leading) {
                    if !isSearchMode && keyword.isEmpty {
                        Text(themeNameLabel)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isFocused ? Color.gray60 : .black )
                            .transition(.opacity)
                    }
                    TextField("", text: $keyword)
                        .font(.system(size: 17, weight: .semibold))
                        .focused($isFocused)
                }
                Text("목록에서 검색")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isFocused ? Color.gray60 : .black )
            }
        }
    }
    
    private var trailingView: some View {
        HStack(spacing: 0) {
            VerticalDivider(padding: 16)
                .opacity(isSearchMode ? 1 : 0)
            ExploreThemeDismissButton($isFocused, $keyword, $isSearchMode)
            ExploreThemeButton($isFocused, $isSearchMode, theme, onShowThemePicker)
        }
    }
}
