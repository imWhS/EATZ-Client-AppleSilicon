//
//  TodayCookableSearchCriteria.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/11/25.
//

import Foundation

struct CookableSearchCriteria: Equatable, Codable, Hashable {
    var keyword: String = ""
    var maxTotalTime: Int?
    var servings: Int? 
    var isCookableOnly: Bool = true
    
    var isDefault: Bool {
        keyword.isEmpty && maxTotalTime == nil && servings == nil && isCookableOnly
    }
}
