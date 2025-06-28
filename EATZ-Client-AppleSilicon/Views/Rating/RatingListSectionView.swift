//
//  RatingListSectionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/26/25.
//

import SwiftUI

struct RatingListSectionView: View {
    let ratings: [RatingItem]
    let canManage: () -> Bool
    let onHide: (Int64) -> Void
    let onDelete: (RatingItem) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("모든 평가")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 20)
            
            LazyVStack(spacing: 20) {
                ForEach(ratings, id: \.id) { rating in
                    RatingCardView(
                        rating: rating,
                        canManageRating: canManage(),
                        onHide: onHide,
                        onDelete: onDelete
                    )
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .animation(.easeInOut, value: ratings)
        }
        .padding(.vertical, 20)
    }
}
