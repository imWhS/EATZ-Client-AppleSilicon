//
//  RatingSummary.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import Foundation

struct RatingIndicator: Decodable, Equatable {
    let summary: RatingIndicatorSummary
    let scoresDistribution: RatingIndicatorScoresDistribution
}
