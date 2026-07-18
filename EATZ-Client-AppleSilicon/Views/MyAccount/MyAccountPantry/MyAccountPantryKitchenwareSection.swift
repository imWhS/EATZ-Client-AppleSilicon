//
//  MyAccountPantryKitchenwareSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct MyAccountPantryKitchenwareSection: View {
    let count: Int?
    let onSearchKitchenwares: () -> Void
    let onDetailTapped: () -> Void
    
    var body: some View {
        if let count = count {
            VStack {
                VStack(spacing: 0) {
                    MyAccountPantryHeader(title: "도구")
                    contentView(count)
                }
                .padding(.top, 10)
                HorizontalDivider()
            }
        }
    }
    
    @ViewBuilder
    private func contentView(_ count: Int) -> some View {
        MyAccountPantryItemContainer(title: "내 도구 보관함", count: count, onDetailTapped: onDetailTapped) {
            HStack {
                VerticalAlignedButton(image: "search-18", title: "도구 둘러보기", verticalPadding: 12, highlightCornerRadius: 12, action: onSearchKitchenwares)
            }
            .padding(8)
        }
    }
}
