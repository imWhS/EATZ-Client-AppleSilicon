//
//  RecipeResponse.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 3/31/25.
//

import Foundation

struct RecipeResponse: Codable {
    
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
    let ingredients: [RecipeIngredient]?
    let categories: [RecipeCategory]
    let commentCount: Int64
    let likedCount: Int64
    let rating: RatingSummary?
    
}

struct Author: Codable {
    let id: Int64
    let username: String
    let imageUrl: String?
    let recipeCount: Int64?
}

struct RecipeIngredient: Codable {
    let id: Int64
    let name: String
    let ownedByUser: Bool?
}

struct RecipeCategory: Codable, Identifiable {
    let id: Int64
    let name: String
}

struct RatingSummary: Codable {
    let count: Int64
    let averageScore: Double?
}
