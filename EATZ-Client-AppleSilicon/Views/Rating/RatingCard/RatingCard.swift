//
//  RatingCard.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/19/25.
//

import SwiftUI

struct RatingCard<Footer: View>: View {
    let rating: Rating
    @ViewBuilder let footerView: Footer
    
    var body: some View {
        VStack(spacing: 8) {
            contentView
            footerView
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private var contentView: some View {
        VStack(spacing: 16) {
            RatingCardHeaderView(
                imageUrl: rating.author.imageUrl,
                username: rating.author.username,
                score: rating.score,
                createdAt: rating.createdAt)
            RatingCardContentView(content: rating.content)
        }
        .padding(24)
        .background(Color.backgroundPrimary)
        .cornerRadius(24)
        .padding(.horizontal, 20)
    }
}
