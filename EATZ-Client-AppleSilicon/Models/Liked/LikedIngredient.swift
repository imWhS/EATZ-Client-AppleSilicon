//
//  LikedIngredient.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/20/25.
//

import Foundation

struct LikedIngredient : Decodable {
    let id: Int64
    let ingredientId: Int64
    let liked: Bool
    let count: Int
    let createdAt: Date
    let updatedAt: Date
}
