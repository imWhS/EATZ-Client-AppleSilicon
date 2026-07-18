//
//  RecipeForUpdate.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 3/31/25.
//

import Foundation

struct RecipeEditable: Codable, Equatable, Hashable {
    let id: Int64
    let title: String
    let url: String
    let imageUrl: String
    let description: String
    let cookingTime: Int
    let prepTime: Int?
    let servings: Int
    let creatorName: String?
    let creatorUrl: String?
    let kitchenwares: [KitchenwareEssential]
    let ingredients: [IngredientEssential]
    let tagNames: [String]
    let isCommentEnabled: Bool
}

