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
        Button(action: {
            isFocused.toggle()
            isSearchMode.toggle()
        }) {
            HStack(spacing: 4) {
                leadingSection
                trailingSection
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchMode)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
            .onChange(of: isFocused) { _, isFocused in
                /// `isFocused`가 `true`인 경우에만 검색 모드로 전환합니다.
                /// 다른 뷰가 push되는 등의 이유로 `isFocused`가 `false`가 되더라도, 검색 모드를 해제하지 않도록 처리합니다.
                if isFocused { self.isSearchMode = isFocused }
            }
        }
        .buttonStyle(ExploreSearchBarScaleStyle())
        .frame(maxHeight: 66)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var leadingSection: some View {
        HStack(spacing: 8) {
            Group {
                Image("search-18")
                    .foregroundStyle(isFocused ? Color.accentColor : .black)
                    .padding(.leading, 20)
                VStack(alignment: .leading, spacing: 2) {
                    ZStack(alignment: .leading) {
                        Group {
                            if !isSearchMode && keyword.isEmpty {
                                Text(themeNameLabel)
                                    .foregroundStyle(isFocused ? Color.gray60 : .black )
                                    .transition(.opacity)
                            }
                            TextField("", text: $keyword)
                                .focused($isFocused)
                                .allowsHitTesting(isFocused) // 포커스가 없을 때에는 터치 이벤트를 무시해서, 상위 Button이 대신 받도록 처리합니다.
                        }
                        .font(.system(size: 17, weight: .semibold))
                    }
                    Text("목록에서 검색")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isFocused ? Color.gray60 : .black )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isFocused)
        }
    }
    
    private var trailingSection: some View {
        HStack(spacing: 0) {
            VerticalDivider(padding: 16)
                .opacity(isSearchMode ? 1 : 0)
            ExploreSearchBarDismissButton($isFocused, $keyword, $isSearchMode)
            ExploreSearchBarThemeButton($isFocused, $isSearchMode, theme, onShowThemePicker)
        }
    }
}

private struct ExploreSearchBarScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(
                        color: .black.opacity(configuration.isPressed ? 0.0275 : 0.125),
                        radius: configuration.isPressed ? 6 : 12,
                        y: configuration.isPressed ? 4 : 6
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                configuration.isPressed
                    ? .interactiveSpring(response: 0.15, dampingFraction: 1.0)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
