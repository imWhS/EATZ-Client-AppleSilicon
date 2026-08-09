//
//  ViewRoute.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/14/25.
//

import Foundation

enum ViewRoute: Hashable {
    case recipe(id: Int64)
    case rating(recipeId: Int64)
    case comment(recipeId: Int64)
    case profile(userId: Int64)
    case checklist(startDate: Date, endDate: Date)
    case cookable(searchCriteria: CookableSearchCriteria)
    case myRecipes
    case savedRecipes
    case likedRecipes
    case ratedRecipes
    case myIngredientPantry
    case myKitchenwarePantry
    case myAccountSettings
    case userBlocklist
    case openSourceLicense
    case deleteAccount
    case deleteAccountDetail
}
