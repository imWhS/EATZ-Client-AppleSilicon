//
//  RatingSummaryView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingSummaryView: View {
    let state: RatingSummaryState

    var body: some View {
        Group {
            switch state {
            case .loading:
                VStack(spacing: 20) {
                    RatingSummaryAverageView(isPlaceholder: true)
                    RatingSummaryDistributionView(isPlaceholder: true)
                }
            case .loaded(let summary):
                VStack(spacing: 20) {
                    RatingSummaryAverageView(
                        averageScore: summary.average.averageScore,
                        count: summary.average.count)
                    RatingSummaryDistributionView(distribution: RatingDistribution(
                        countScore5: summary.distribution.countScore5,
                        countScore4: summary.distribution.countScore4,
                        countScore3: summary.distribution.countScore3,
                        countScore2: summary.distribution.countScore2,
                        countScore1: summary.distribution.countScore1
                    ))
                }
                
            case .error(let message):
                VStack(spacing: 8) {
                    Text("죄송합니다. 평가 요약 정보를 불러오지 못했어요.")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                }
            }
        }
        .padding(.vertical, 20)
    }
}
