//
//  RatingIndicatorScoresDistribution.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 4/16/26.
//

import Foundation

struct RatingIndicatorScoresDistribution: Decodable, Equatable {
    let countScore5: Int
    let countScore4: Int
    let countScore3: Int
    let countScore2: Int
    let countScore1: Int

    var maxCount: Int {
        [countScore5, countScore4, countScore3, countScore2, countScore1].max() ?? 1
    }

    var asArray: [(score: Int, count: Int)] {
        [
            (5, countScore5),
            (4, countScore4),
            (3, countScore3),
            (2, countScore2),
            (1, countScore1)
        ]
    }
}
