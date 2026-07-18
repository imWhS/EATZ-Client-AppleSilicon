//
//  RatingDraft.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/13/26.
//

import Foundation

struct RatingDraft: Equatable {
    var score: Int = 0
    var content: String = ""
    
    init(from rating: Rating? = nil) {
        if let rating = rating {
            score = rating.score
            content = rating.content
        } else {
            score = 0
            content = ""
        }
    }
    
    func hasInvalidScore() -> Bool {
        1 <= score && score <= 5
    }
}

