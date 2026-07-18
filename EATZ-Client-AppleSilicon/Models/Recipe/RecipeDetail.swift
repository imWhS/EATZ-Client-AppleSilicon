//
//  RecipeDetail.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct RecipeDetail: Equatable, Hashable, Decodable, Identifiable {
    let id: Int64
    let title: String
    let imageUrl: String?
    let cookingTime: Int?
    let prepTime: Int?
    let createdAt: Date
    let updatedAt: Date
    let viewCount: Int
    let author: RecipeDetail.Author
    let commentCount: Int
    let likedCount: Int
    let savedByUser: Bool
    let savedCount: Int64
    let ingredients: [IngredientEssential]
    let tags: [TagListItem]
    let ratingCount: Int
    let ratingAverageScore: Double?
    let likedByUser: Bool?
    
    struct Author: Equatable, Hashable, Decodable {
        let id: Int64
        let username: String
        let imageUrl: String?
    }
}
