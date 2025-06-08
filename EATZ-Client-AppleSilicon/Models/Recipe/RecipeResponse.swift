//
//  RecipeResponse.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 3/31/25.
//

import Foundation

struct RecipeResponse: Codable, Equatable {
    let id: Int64
    let title: String
    let description: String
    let imageUrl: String
    let cookingTime: Int?
    let prepTime: Int?
    let createdAt: String
    let updatedAt: String
    let viewCount: Int
    let author: Author
    let categories: [RecipeCategory]
    let commentCount: Int64
    let likedCount: Int64
    let rating: RatingSummaryBasic?
    let liked: Bool
}

struct RecipeIngredient: Codable, Equatable {
    let id: Int64
    let name: String
    var ownedByUser: Bool
}

struct RecipeCategory: Codable, Identifiable, Equatable {
    let id: Int64
    let name: String
}

struct RatingSummaryBasic: Codable, Equatable {
    let count: Int64
    let averageScore: Double?
}
