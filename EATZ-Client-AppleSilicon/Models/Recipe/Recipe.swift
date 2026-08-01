//
//  Recipe.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 3/31/25.
//

import Foundation

struct Recipe: Codable, Equatable, Hashable {
    let id: Int64
    let title: String
    let description: String
//    let url: String
    let imageUrl: String
    let cookingTime: Int?
    let prepTime: Int?
    let creatorName: String?
    let creatorUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let commentEnabled: Bool
    let viewCount: Int
    let author: Author
    let tags: [RecipeTag]
    let servings: Int
    let ratingIndicatorSummary: RatingIndicatorSummary?
    var commentCount: Int
    var likedCount: Int
    var liked: Bool
    var saved: Bool
}

struct RecipeIngredient: Codable, Equatable, Hashable, Identifiable, IngredientDisplayable {
    var id: Int64
    var parentCoupled: Bool
    var coupledParentName: String?
    var name: String
    var hasChildren: Bool { false }
    var ownedByUser: Bool
    var likedByUser: Bool
}

struct RecipeKitchenware: Codable, Equatable, Hashable, Identifiable, KitchenwareDisplayable {
    let id: Int64
    let name: String
    let imageUrl: String?
    var ownedByUser: Bool
}

struct RecipeTag: Codable, Identifiable, Equatable, Hashable {
    let id: Int64
    let name: String
}

struct RatingIndicatorSummary: Codable, Equatable, Hashable {
    let count: Int
    let averageScore: Double?
}
