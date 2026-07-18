//
//  CookableRecipe.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/5/25.
//

import Foundation

struct CookableRecipe: Codable, Hashable, Identifiable {
    let id: Int64
    let title: String
    let imageUrl: String?
    let servings: Int?
    let cookingTime: Int?
    let prepTime: Int?
    let authorId: Int64
    let authorUsername: String
    
    let likedCount: Int
    let ratingCount: Int
    let ratingAverageScore: Double
    
    let likedByUser: Bool
    var savedByUser: Bool
    
    let missingIngredientCount: Int?
    let missingKitchenwareCount: Int?
}
