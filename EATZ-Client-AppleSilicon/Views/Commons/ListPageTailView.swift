//
//  ListPageTailView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/17/25.
//

import SwiftUI

struct ListPageTailView: View {
    let hasNextPage: Bool?
    var onAppearAction: () -> Void = {}
    var onDisappearAction: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .center) {
            if let hasNextPage = hasNextPage, hasNextPage {
                HStack {
                    ProgressView()
                    labelView(text: "더 불러오고 있어요...")
                }
            } else {
                labelView(text: "마지막 항목까지 모두 확인했어요.")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .task { onAppearAction() }
        .onDisappear { onDisappearAction() }
    }
    
    private func labelView(text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.gray20)
    }
}

#Preview {
    let hasNextPage = true
    ListPageTailView(hasNextPage: hasNextPage)
}
