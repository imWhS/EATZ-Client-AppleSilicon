//
//  LikedRecipe.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/20/25.
//

import Foundation

struct LikedRecipe : Decodable {
    let id: Int64
    let recipeId: Int64
    let liked: Bool
    let count: Int
    let createdAt: Date
    let updatedAt: Date
}
