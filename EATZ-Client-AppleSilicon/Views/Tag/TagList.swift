//
//  TagList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/16/25.
//

import SwiftUI

struct TagList: View {
    let pagedTags: Paged<Tag>
    let onSelect: (Tag) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                searchResultHeader
                LazyVStack(spacing: 0) {
                    ForEach(pagedTags.items) { tag in
                        TagItem(name: tag.name) {
                            onSelect(tag)
                        }
                    }
                    ListPageTailView(hasNextPage: pagedTags.hasNextPage, onAppear: onLoadMore)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var searchResultHeader: some View {
        HStack {
            Text("연관 태그 추가")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray35)
            Spacer()
        }
        .padding(.horizontal ,20)
        .padding(.top ,20)
        .padding(.bottom, 8)
    }
}
