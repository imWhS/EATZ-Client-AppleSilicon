//
//  CommentListView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/20/25.
//

import SwiftUI

struct CommentList: View {
    let pagedCommentsWithPermissions: Paged<CommentWithPermissions>
    let onLoadNextPage: () -> Void
    let action: (Comment, CommentItemAction) -> Void
    
    init(
        _ pagedCommentsWithPermissions: Paged<CommentWithPermissions>,
        _ onLoadNextPage: @escaping () -> Void,
        _ action: @escaping (Comment, CommentItemAction) -> Void
    ) {
        self.pagedCommentsWithPermissions = pagedCommentsWithPermissions
        self.onLoadNextPage = onLoadNextPage
        self.action = action
    }
    
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 0) {
            ForEach(pagedCommentsWithPermissions.items) { pagedCommentWithPermissions in
                CommentItem(
                    pagedCommentWithPermissions.comment,
                    pagedCommentWithPermissions.permissions,
                    action)
            }
            
            if !pagedCommentsWithPermissions.isEmpty {
                ListPageTailView(
                    hasNextPage: pagedCommentsWithPermissions.hasNextPage,
                    onAppear: onLoadNextPage)
                .id(pagedCommentsWithPermissions.items.count)
            }
        }
        .animation(.easeInOut, value: pagedCommentsWithPermissions.items)
    }
}
