//
//  ExploreRecipesRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 4/9/26.
//

import Foundation

struct ExploreRecipesRequest: Encodable {
    let keyword: String
    let maxTotalTime: Int?
    let servings: Int?
    let tagId: Int64?
    let sort: ExploreRecipesSort
    
    let page: Int
    let size: Int
    
    init(searchCriteria: ExploreSearchCriteria, page: Int, size: Int) {
        self.keyword = searchCriteria.keyword
        self.maxTotalTime = searchCriteria.maxTotalTime
        self.servings = searchCriteria.servings
        self.tagId = searchCriteria.tagId
        self.sort = searchCriteria.sort
        self.page = page
        self.size = size
    }
}
