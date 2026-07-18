//
//  ExploreRecipesResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/14/25.
//

import Foundation

struct ExploreRecipesResponse : Decodable {
    let content: [ExploreRecipe]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
