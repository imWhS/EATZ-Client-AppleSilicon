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
            keywordAreaView
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
            print("## is search mode: \(isSearchMode)")
        }
    }
    
    private var keywordAreaView: some View {
        HStack(spacing: 8) {
            Image("recipe-list-search")
                .padding(.leading, 20)
            VStack(alignment: .leading, spacing: 2) {
                ZStack(alignment: .leading) {
                    if !isSearchMode && keyword.isEmpty {
                        Text(themeNameLabel)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isFocused ? Color.init(hex: "707070") : .black )
                            .transition(.opacity)
                    }
                    TextField("", text: $keyword)
                        .font(.system(size: 17, weight: .semibold))
                        .focused($isFocused)
                }
                Text("목록에서 검색")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isFocused ? Color.init(hex: "707070") : .black )
            }
        }
    }
    
    private var trailingView: some View {
        HStack(spacing: 0) {
            VerticalDivider(padding: 16)
                .opacity(isSearchMode ? 1 : 0)
            cancelButton
            themeButton
        }
    }
    
    private var cancelButton: some View {
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
        .clipped() // 너비가 0일 때 뷰가 영역을 차지하지 않도록 잘라냅니다.
        .allowsHitTesting(isSearchMode) // 보일 때만 탭할 수 있도록 처리합니다.
    }
    
    private var themeButton: some View {
        Button(action: {
            isFocused = false
            onShowThemePicker()
        }) {
            HStack(spacing: 0) {
                Image("category")
                    .padding(.leading, 11)
                
                // 카테고리 라벨: isFocused 상태에 따라 너비가 변합니다.
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
            .frame(maxHeight: 34)
            .frame(minWidth: 34)
            .background(theme != nil ? Color.accentColor : Color.init(hex: "ECECEC"))
            .clipShape(Capsule())
            .padding(.trailing, 16)
        }
        .foregroundStyle(Color.accentColor)
        .buttonStyle(ScaleDownButtonStyle())
    }
}
