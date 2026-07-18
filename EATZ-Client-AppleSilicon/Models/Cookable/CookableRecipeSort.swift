//
//  CookableRecipeSort.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/11/25.
//

import Foundation

enum CookableRecipeSort: String, Codable, CaseIterable, Equatable, Sortable {
    case FEWEST_MISSING_REQUIREMENTS
    case TRENDING
    case LATEST
    case HIGHEST_RATED
    case MOST_LIKED
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .FEWEST_MISSING_REQUIREMENTS: return "적은 준비물"
        case .TRENDING: return "추천"
        case .LATEST: return "최근 등록됨"
        case .HIGHEST_RATED: return "높은 평가 평균 점수"
        case .MOST_LIKED: return "높은 좋아요 수"
        }
    }
}
