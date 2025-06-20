//
//  RatingView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingSummaryView: View {
    let summary: RatingSummaryResponse

    var body: some View {
        VStack(spacing: 20) {
            RatingSummaryAverageView(
                averageScore: summary.average.averageScore,
                count: summary.average.count
            )
            RatingSummaryDistributionView(distribution: RatingDistribution(
                countScore5: summary.distribution.countScore5,
                countScore4: summary.distribution.countScore4,
                countScore3: summary.distribution.countScore3,
                countScore2: summary.distribution.countScore2,
                countScore1: summary.distribution.countScore1
            ))
        }
    }
}

#Preview {
    RatingSummaryView(
        summary: RatingSummaryResponse(
            average: .init(count: 1, averageScore: 4.5),
            distribution: .init(
                countScore5: 0,
                countScore4: 0,
                countScore3: 0,
                countScore2: 0,
                countScore1: 1
            )
        )
    )
}
