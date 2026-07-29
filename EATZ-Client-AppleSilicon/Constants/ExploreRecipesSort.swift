//
//  ExploreRecipesSort.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 4/9/26.
//

import Foundation

enum ExploreRecipesSort: String, Identifiable, Codable, CaseIterable, Equatable, Sortable {
    case TRENDING
    case LATEST
    case HIGHEST_RATED
    case MOST_LIKED
    
    var id: Self { self }
    
    /// 뷰에 사용하는 한글 이름입니다.
    var displayName: String {
        switch self {
        case .TRENDING: return "추천"
        case .LATEST: return "최근 등록됨"
        case .HIGHEST_RATED: return "높은 평가 평균 점수"
        case .MOST_LIKED: return "높은 좋아요 수"
        }
    }
}
