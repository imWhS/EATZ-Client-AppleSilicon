//
//  ExploreSearchCriteria.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/11/25.
//

import Foundation

 struct ExploreSearchCriteria: Equatable, Codable, Hashable {
    var keyword: String = ""
    var maxTotalTime: Int?
    var servings: Int?
    var tagId: Int64? 
    var sort: ExploreRecipesSort
    
    var isDefault: Bool {
        keyword.isEmpty && maxTotalTime == nil && servings == nil && tagId == nil && sort == .TRENDING
    }
}
