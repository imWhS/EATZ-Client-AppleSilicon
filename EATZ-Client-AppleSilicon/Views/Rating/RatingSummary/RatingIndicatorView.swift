//
//  RatingIndicatorView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingIndicatorView: View {
    let state: RatingIndicatorState

    var body: some View {
        Group {
            switch state {
            case .initialLoading:
                VStack(spacing: 20) {
                    RatingIndicatorAverageView(isPlaceholder: true)
                    RatingIndicatorDistributionView(isPlaceholder: true)
                }
            case .loaded(let summary):
                VStack(spacing: 20) {
                    RatingIndicatorAverageView(
                        averageScore: summary.summary.averageScore,
                        count: summary.summary.count)
                    RatingIndicatorDistributionView(distribution: RatingIndicatorScoresDistribution(
                        countScore5: summary.scoresDistribution.countScore5,
                        countScore4: summary.scoresDistribution.countScore4,
                        countScore3: summary.scoresDistribution.countScore3,
                        countScore2: summary.scoresDistribution.countScore2,
                        countScore1: summary.scoresDistribution.countScore1
                    ))
                }
                
            case .error(let message): ErrorCurtain("평가 지표를 불러오지 못했어요.")
            }
        }
        .padding(.vertical, 40)
    }
}
