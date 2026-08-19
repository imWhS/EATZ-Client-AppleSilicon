//
//  FetchTodayCookableList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation

struct FetchCookableListRequest : Encodable {
    let keyword: String
    let maxTotalTime: Int?
    let servings: Int?
    let isCookableOnly: Bool
    
    let sort: CookableRecipesSort
    
    let page: Int
    let size: Int
}
