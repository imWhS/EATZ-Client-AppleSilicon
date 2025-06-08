//
//  RatingSummaryDistributionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingSummaryDistributionView: View {
    let distribution: RatingDistribution
    
    var body: some View {
        VStack {
            ForEach(Array(distribution.asArray.enumerated()), id: \.1.score) { index, tuple in
                RatingBarView(
                    score: tuple.score,
                    count: tuple.count,
                    maxCount: distribution.maxCount,
                    delay: Double(index) * 0.07
                )
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    RatingSummaryDistributionView(distribution: RatingDistribution(
        countScore5: 3, countScore4: 2, countScore3: 5, countScore2: 20, countScore1: 1
    ))
}
