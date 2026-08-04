//
//  EssentialRecipeSearchBar.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/19/25.
//

import SwiftUI

enum EssentialRecipeSearchBarStyle {
    case normal
    case floating
}

struct EssentialRecipeSearchBar: View {
    @Binding var keyword: String
    @FocusState.Binding var isFocused: Bool
    @State private var cancelButtonWidth: CGFloat = 0
    var style: EssentialRecipeSearchBarStyle
    
    var onCancel: () -> Void
    
    var body: some View {
        mainContent
        .onPreferenceChange(CancelButtonWidthKey.self) { width in
            self.cancelButtonWidth = width
        }
        .onTapGesture {
            isFocused = true
        }
    }
    
    private var mainContent: some View {
        HStack {
            ZStack {
                HStack(spacing: 0) {
                    EssentialRecipeSearchBarField(keyword: $keyword, isFocused: $isFocused, onClear: { keyword = "" })
                    cancelButton
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
            }
            .padding(.vertical, 12)
            .background(isFocused || style == .floating ? Color.white : Color.gray8)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isFocused ? Color.init(hex: "E3E3E3") : Color.clear, lineWidth: 1)
            )
            .shadow(color: style == .floating ? Color.black.opacity(0.15) : Color.black.opacity(0), radius: 16, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
    }
    
    private var cancelButton: some View {
        Button(action: {
            keyword = ""
            isFocused = false
            onCancel()
        }) {
            Text("취소")
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.buttonSecondary)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 14)
        .offset(x: isFocused ? 0 : cancelButtonWidth + 14)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: CancelButtonWidthKey.self, value: geometry.size.width)
            }
        )
    }
}

private struct EssentialRecipeSearchBarField: View {
    @Binding var keyword: String
    @FocusState.Binding var isFocused: Bool
    let onClear: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            HStack {
                Image("search-18")
                    .foregroundStyle(isFocused ? .black : Color.gray60 )
                VStack(alignment: .leading, spacing: 2) {
                    searchFieldTopSection
                    searchFieldBottomSection
                }
            }
            .padding(.leading, 12)
            
            if (isFocused && !keyword.isEmpty) { clearSearchFieldButton }
        }
    }
    
    private var searchFieldTopSection: some View {
        ZStack(alignment: .leading) {
            if !isFocused && keyword.isEmpty {
                Text("레시피 제목, 내용")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.gray60)
            }
            TextField("", text: $keyword)
                .font(.system(size: 17, weight: .semibold))
                .focused($isFocused)
        }
    }
    
    private var searchFieldBottomSection: some View {
        Text("레시피 검색")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(isFocused ? .black : Color.gray60 )
    }
    
    private var clearSearchFieldButton: some View {
        Button(action: onClear) {
            Image("remove-14")
        }
        .padding(.vertical, 6)
        .padding(.leading, 6)
        .padding(.trailing, 12)
    }
}

struct CancelButtonWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text: String = ""
        @FocusState private var isSearchFieldFocused: Bool
        
        var body: some View {
            EssentialRecipeSearchBar(keyword: $text, isFocused: $isSearchFieldFocused, style: .normal) {}
        }
        
    }
    
    return PreviewWrapper()
}
