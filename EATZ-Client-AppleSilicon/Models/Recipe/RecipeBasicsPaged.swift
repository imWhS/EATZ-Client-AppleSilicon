//
//  SavedRecipeDetailsPaged.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/20/25.
//

import Foundation

struct RecipeBasicsPaged : Decodable {
    let content: [RecipeBasic]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}


