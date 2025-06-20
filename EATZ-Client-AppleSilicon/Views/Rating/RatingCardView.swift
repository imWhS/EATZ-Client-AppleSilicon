//
//  RatingCardView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingCardView: View {
    let rating: RatingItem
    let canManageRating: Bool
    let onHide: (() -> Void)?
    let onDelete: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        ProfileImageView(imageUrl: rating.user.imageUrl, size: 32)
                        Text(rating.user.username)
                            .font(.system(size: 12, weight: .bold))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        RatingStarsView(score: rating.score, starSize: 18)
                        .frame(height: 32)
                        HStack {
                            Text("\(rating.createdAt)")
                            Text("\(rating.score)점")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .font(.system(size: 12))
                    }
                }
                HorizontalDividerView(horizontalPadding: 0)
                Text(rating.content)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .background(Color.init("F9F9F9"))
            .cornerRadius(24)
            .padding(.horizontal, 20)
            
            if canManageRating {
                HStack(spacing: 0) {
                    Spacer()
                    Button("숨기기") {
                        onHide?()
                    }
                    .buttonStyle(SmallBorderlessButtonStyle())
                    Button("삭제하기") {
                        onDelete?()
                    }
                    .buttonStyle(SmallBorderlessButtonStyle())
                }
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 8)
            }
        }
        
    }
}

#Preview {
    let user = UserBasic(
        id: 1,
        username: "hee.xtory",
        imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgRpKzCD0qaHBwI03JFHGakAPxGdv5yOIk-vkhqp0nY3B_y9J-Nn5PQwu34h0Aq81jXuA&usqp=CAU"
    )
    let rating = RatingItem(
        id: 1,
        user: user,
        score: 4,
        content: "고춧가루를 안 넣어서 그런지 양념이 녹진하지 않고 약간 애매했어요! ㅠㅠ 다음에 재료 다 구해서 다시 만들어보고 평가 남길게요!",
        createdAt: "2025-05-24 12:05:17"
    )

    RatingCardView(
        rating: rating,
        canManageRating: true,
        onHide: { print("숨기기") },
        onDelete: { print("삭제하기") }
    )
}
