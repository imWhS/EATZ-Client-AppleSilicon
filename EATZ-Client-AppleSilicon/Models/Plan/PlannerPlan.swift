//
//  PlannerPlan.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/3/25.
//

import Foundation

struct PlannerPlan: Codable, Identifiable, Equatable {
    let id: Int64
    let recipeId: Int64
    let userId: Int64
    let recipeTitle: String
    let recipeImageUrl: String
    let recipeCookingTime: Int?
    let recipePrepTime: Int?
    let recipeAuthorId: Int64
    let recipeAuthorUsername: String
    let scheduledAt: Date
    let ratingIndicatorSummary: RatingIndicatorSummary?
    var likedRecipeByUser: Bool
    var savedRecipeByUser: Bool
    var ownedRecipeByUser: Bool
}
