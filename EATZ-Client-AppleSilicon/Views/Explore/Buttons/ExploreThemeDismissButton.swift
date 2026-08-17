//
//  ExploreThemeDismissButton.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct ExploreThemeDismissButton: View {
    @FocusState.Binding var isFocused: Bool
    @Binding var keyword: String
    @Binding var isSearchMode: Bool
    
    init(_ isFocused: FocusState<Bool>.Binding, _ keyword: Binding<String>, _ isSearchMode: Binding<Bool>) {
        self._isFocused = isFocused
        self._keyword = keyword
        self._isSearchMode = isSearchMode
    }
    
    var body: some View {
        Button("취소", action: {
            keyword = ""
            isFocused = false
            isSearchMode = false
        })
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(Color.accentColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .fixedSize() // 크기가 변할 때 내부 텍스트가 잘리지 않도록 고정합니다.
        .frame(width: isSearchMode ? nil : 0, alignment: .trailing)
        .opacity(isSearchMode ? 1 : 0)
        .clipped()
        .allowsHitTesting(isSearchMode) // 보일 때만 탭할 수 있도록 처리합니다.
    }
}
