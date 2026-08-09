//
//  RatingList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/26/25.
//

import SwiftUI

struct RatingList: View {
    @State private var timerTask: Task<Void, Never>?
    
    let pagedRatings: Paged<RatingWithPermissions>
    let loadMore: () -> Void
    let onDelete: (RatingDeleteActionType) -> Void
    let onBlock: (UserEssential) -> Void
    let onReport: (Rating) -> Void
    let onHide: (Int64) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            RatingSectionCommonHeaderView(title: "모든 평가")
            listView()
        }
        .padding(.vertical, 20)
    }
    
    func listView() -> some View {
        return LazyVStack(spacing: 0) {
            ForEach(pagedRatings.items) { rating in
                ratingCard(rating)
            }
            
            if !pagedRatings.isEmpty {
                ListPageTailView(hasNextPage: pagedRatings.hasNextPage, onAppear: loadMore)
                    .id(pagedRatings.items.count)
            }
        }
        .padding(.vertical, 10)
    }
    
    private func ratingCard(_ ratingWithPermission: RatingWithPermissions) -> some View {
        RatingCard(rating: ratingWithPermission.rating) {
            managementInteractionsView(
                permissions: ratingWithPermission.permissions,
                onDelete: { onDelete(RatingDeleteActionType.other(ratingWithPermission.rating)) },
                onBlock: { onBlock(ratingWithPermission.rating.author) },
                onReport: { onReport(ratingWithPermission.rating) },
                onHide: { onHide(ratingWithPermission.id) })
        }
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    func managementInteractionsView(
        permissions: Set<RatingPermission>,
        onDelete: @escaping () -> Void,
        onBlock: @escaping () -> Void,
        onReport: @escaping () -> Void,
        onHide: @escaping () -> Void
    ) -> some View {
        if permissions.isEmpty { EmptyView() }
        else {
            HStack(spacing: 8) {
                Spacer()
                Group {
                    if permissions.contains(.block) { Button("작성자 차단", action: onBlock) }
                    if permissions.contains(.report) { Button("신고", action: onReport) }
                    if permissions.contains(.delete) { Button("삭제", action: onDelete) }
//                    if permissions.contains(.hide) { Button("숨김", action: onHide) }
                }
                .font(.system(size: 12, weight: .semibold))
                .buttonStyle(SmallBorderlessButtonStyle())
            }
            .padding(.horizontal, 12)
        }
    }
}


