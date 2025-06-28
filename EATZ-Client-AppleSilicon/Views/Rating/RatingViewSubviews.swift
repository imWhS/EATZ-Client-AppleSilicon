//
//  RatingViewSubviews.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/23/25.
//

import SwiftUI
import Kingfisher

struct RatingLoadingView: View {
    var body: some View {
        ProgressView("평가 요약 불러오는 중...")
            .toolbarBackground(.visible, for: .tabBar)
    }
}

struct RatingErrorView: View {
    let message: String
    var body: some View {
        VStack(spacing: 8) {
            Text("평가 정보를 가져오지 못했어요.")
                .font(.system(size: 18, weight: .bold))
            Text("\(message)")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.init("8F8F8F"))
        }
    }
}


struct RatingsListView: View {
    let ratings: [RatingItem]
    let canManage: () -> Bool
    let onHide: (Int64) -> Void
    let onDelete: (RatingItem) -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("모든 평가 (\(ratings.count))")
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
    }
}
