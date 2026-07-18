//
//  ExploreRecipe.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/7/25.
//

import Foundation

struct ExploreRecipe: Codable, Hashable, Identifiable {
    let id: Int64
    let title: String
    let imageUrl: String?
    let servings: Int?
    let cookingTime: Int?
    let prepTime: Int?
    let authorId: Int64
    let authorUsername: String
    let commentEnabled: Bool
    var likedCount: Int
    let commentCount: Int
    let ratingCount: Int
    let ratingAverageScore: Double
    var ownedByUser: Bool
    var likedByUser: Bool
    var savedByUser: Bool
}
