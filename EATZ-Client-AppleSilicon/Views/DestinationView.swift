//
//  DestinationView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/15/25.
//

import SwiftUI

struct DestinationView: View {
    let route: ViewRoute
    
    init(_ route: ViewRoute) {
        self.route = route
    }
    
    var body: some View {
        switch route {
        case .recipe(let id):
//            RecipeView(recipeId: id)
            RecipeViewN(recipeId: id)
        case .rating(let recipeId):
            RatingViewN(recipeId: recipeId)
        case .comment(let recipeId):
            CommentView(recipeId: recipeId)
        case .profile(let userId):
            Text("프로필: \(userId)")
        case .checklist(let startDate, let endDate):
            ChecklistView(dateRange: (startDate, endDate))
        case .cookable(let searchCriteria):
            CookableRecipeListView(searchCriteria: searchCriteria)
        case .myRecipes:
            MyRecipesView()
        case .savedRecipes:
            SavedRecipesView()
        case .likedRecipes:
            LikedRecipesView()
        case .ratedRecipes:
            RatedRecipesView()
        case .myIngredientPantry:
            MyIngredientPantryView()
        case .myKitchenwarePantry:
            MyKitchenwarePantryView()
        case .myAccountSettings:
            MyAccountSettingsView()
        case .userBlocklist:
            UserBlocklist()
        case .deleteAccount:
            DeleteAccountView()
        case .deleteAccountDetail:
            DeleteAccountDetailView()
        }
    }
}

