//
//  RatingCardHeaderView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/19/25.
//

import SwiftUI

struct RatingCardHeaderView: View {
    let imageUrl: String?
    let username: String
    let score: Int
    let createdAt: Date?
    
    init(imageUrl: String?, username: String, score: Int = 0, createdAt: Date? = nil) {
        self.imageUrl = imageUrl
        self.username = username
        self.score = score
        self.createdAt = createdAt
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                ProfileImageView(imageUrl: imageUrl, size: 32)
                Text(username)
                    .font(.system(size: 12, weight: .semibold))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                RatingScoreStar(score: score, starSize: 18)
                .frame(height: 32)
                HStack {
                    Group {
                        if let createdAt = self.createdAt {
                            Text("\(createdAt.formattedRelative)")
                        }
                        Text("\(score)점")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray35)
                }
                .font(.system(size: 12))
            }
        }
    }
}
