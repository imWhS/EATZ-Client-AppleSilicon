//
//  RecipeUpdateRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/18/25.
//

import Foundation

struct RecipeUpdateRequest : Encodable {
    let imageUrl: String
    let title: String
    let url: String
    let description: String?
    let cookingTime: Int
    let prepTime: Int?
    let servings: Int
    let kitchenwareIds: [Int64]
    let ingredientIds: [Int64]
    let tagNames: [String]
    let creatorName: String?
    let creatorUrl: String?
    let isCommentEnabled: Bool
}
