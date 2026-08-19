//
//  ExploreThemeButton.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct ExploreSearchBarThemeButton: View {
    @FocusState.Binding var isFocused: Bool
    @Binding var isSearchMode: Bool
    let theme: ExploreTagItem?
    let onShowThemePicker: () -> Void
    
    init(
        _ isFocused: FocusState<Bool>.Binding,
        _ isSearchMode: Binding<Bool>,
        _ theme: ExploreTagItem?,
        _ onShowThemePicker: @escaping () -> Void)
    {
        self._isFocused = isFocused
        self._isSearchMode = isSearchMode
        self.theme = theme
        self.onShowThemePicker = onShowThemePicker
    }
    
    var body: some View {
        Button(action: {
            isFocused = false
            onShowThemePicker()
        }) {
            HStack(spacing: 0) {
                Image("category")
                    .padding(.leading, 11)
                
                // isFocused 상태에 따라 너비가 바뀝니다.
                Text("테마")
                    .font(.system(size: 14, weight: .semibold))
                    .fixedSize()
                    .padding(.leading, 9)
                    .frame(width: isSearchMode ? 0 : nil, alignment: .leading)
                    .opacity(isSearchMode ? 0 : 1)
                    .padding(.trailing, 11)
                    .clipped()
            }
            .foregroundStyle(theme != nil ? Color.white : Color.accentColor)
            .frame(minWidth: 34, maxHeight: 34)
            .background(theme != nil ? Color.accentColor : Color.buttonSecondary)
            .clipShape(Capsule())
            .padding(.trailing, 16)
        }
        .foregroundStyle(Color.accentColor)
        .buttonStyle(ScaleDownButtonStyle())
    }
}
