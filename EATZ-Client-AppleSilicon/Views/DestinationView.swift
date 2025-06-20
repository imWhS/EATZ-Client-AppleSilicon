//
//  DestinationView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/15/25.
//

import SwiftUI

struct DestinationView: View {
    let route: ViewRoute
    
    var body: some View {
        switch route {
        case .recipe(let id):
            RecipeView(recipeId: id)
        case .rating(let recipeId, let recipeImageUrl, let recipeTitle, let recipeAuthorUsername):
            RatingView(recipeId: recipeId)
        case .profile(let userId):
            Text("프로필: \(userId)")
        }
    }
}

