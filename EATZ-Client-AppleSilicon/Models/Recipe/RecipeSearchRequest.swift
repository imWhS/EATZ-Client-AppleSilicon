//
//  RecipeSearchRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/19/25.
//

import Foundation

struct RecipeSearchRequest: Codable {
    let type: RecipeSort
    let keyword: String?
    let tagId: Int64?
    let ingredientIds: [Int64]?
    let requiredIngredientIds: [Int64]?
    let kitchenwareIds: [Int64]?
    let requiredKitchenwareIds: [Int64]?
    let page: Int
    let size: Int
}

enum RecipeSort: Codable {
    case latest, highestRated, mostLiked, trending
}
