//
//  CookableListResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/5/25.
//

import Foundation

struct TodayCookableListResponse : Decodable {
    let content: [CookableRecipe]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
