//
//  CommentListView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/20/25.
//

import SwiftUI

struct CommentList: View {
    @State private var timerTask: Task<Void, Never>?
    
    let pagedCommentsWithPermissions: Paged<CommentWithPermissions>
    let onLoadNextPage: () -> Void
    let onBlock: (UserEssential) -> Void
    let onReport: (Comment) -> Void
    let onUpdate: (Int64) -> Void
    let onDelete: (Comment) -> Void
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 0) {
            ForEach(pagedCommentsWithPermissions.items) { pagedCommentWithPermissions in
                CommentItem(
                    pagedCommentWithPermissions.comment,
                    permissions: pagedCommentWithPermissions.permissions,
                    onBlock: onBlock,
                    onReport: onReport,
                    onUpdate: onUpdate,
                    onDelete: onDelete
                )
            }
            
            if !pagedCommentsWithPermissions.isEmpty {
                ListPageTailView(
                    hasNextPage: pagedCommentsWithPermissions.hasNextPage,
                    onAppearAction: onLoadNextPage)
                .id(pagedCommentsWithPermissions.items.count)
            }
        }
        .animation(.easeInOut, value: pagedCommentsWithPermissions.items)
    }
}
