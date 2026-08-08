//
//  RatingIndicatorDistributionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingIndicatorDistributionView: View {
    var distribution: RatingIndicatorScoresDistribution? = nil
    var isPlaceholder: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            if isPlaceholder {
                ForEach(0 ..< 5) { _ in
                    RatingBar(
                        score: 0,
                        count: 0,
                        maxCount: 0,
                        delay: 0
                    )
                    .padding(.horizontal, 20)
                }
            } else if let distribution = distribution {
                ForEach(Array(distribution.asArray.enumerated()), id: \.1.score) { index, tuple in
                    RatingBar(
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
}
