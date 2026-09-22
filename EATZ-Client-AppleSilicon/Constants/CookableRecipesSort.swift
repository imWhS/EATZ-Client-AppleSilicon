//
//  CookableRecipesSort.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/11/25.
//

import Foundation

enum CookableRecipesSort: String, Codable, CaseIterable, Equatable, Sortable {
    case fewestMissingRequirements
    case trending
    case latest
    case highestRated
    case mostLiked
    
    var id: Self { self }
    
    /// 뷰에서 사용하는 한글 이름입니다.
    var displayName: String {
        switch self {
        case .fewestMissingRequirements: return "적은 준비물"
        case .trending: return "추천"
        case .latest: return "최근 등록됨"
        case .highestRated: return "높은 평가 평균 점수"
        case .mostLiked: return "높은 좋아요 수"
        }
    }
}
