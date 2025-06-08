//
//  RatingStarsView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/23/25.
//

import SwiftUI

struct RatingStarsView: View {
    let score: Int
    var starSize: CGFloat = 24
    var spacing: CGFloat = 4
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< 5, id: \.self) { index in
                Image("rating-star")
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .foregroundStyle(index < score ? Color.init("D69E5C") : Color.init("ECECEC"))
            }
        }
    }
}

#Preview {
    RatingStarsView(score: 3)
}
