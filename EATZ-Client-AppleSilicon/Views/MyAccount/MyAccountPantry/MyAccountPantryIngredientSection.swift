//
//  MyAccountPantryIngredientSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct MyAccountPantryIngredientSection: View {
    let count: Int?
    let onSearchIngredients: () -> Void
    let onPresentLikedIngredients: () -> Void
    let onDetailTapped: () -> Void
    
    init(count: Int?,
         onSearchIngredients: @escaping () -> Void,
         onPresentLikedIngredients: @escaping () -> Void,
         onDetailTapped: @escaping () -> Void) {
        self.count = count
        self.onSearchIngredients = onSearchIngredients
        self.onPresentLikedIngredients = onPresentLikedIngredients
        self.onDetailTapped = onDetailTapped
    }
    
    var body: some View {
        if let count = count {
            VStack {
                VStack(spacing: 0) {
                    MyAccountPantryHeader(title: "재료")
                    contentView(count)
                }
                .padding(.top, 10)
                HorizontalDivider()
            }
        }
    }
    
    @ViewBuilder
    private func contentView(_ count: Int) -> some View {
        MyAccountPantryItemContainer(title: "내 재료 보관함", count: count, onDetailTapped: onDetailTapped) {
            HStack(spacing: 4) {
                VerticalAlignedButton(image: "search-18", title: "재료 둘러보기", verticalPadding: 8, highlightCornerRadius: 8, action: onSearchIngredients)
                VerticalDivider(padding: 8)
                VerticalAlignedButton(image: "like-filled-16", title: "좋아하는 재료", verticalPadding: 8, highlightCornerRadius: 8, action: onPresentLikedIngredients)
            }
            .padding(8)
        }
    }
}
