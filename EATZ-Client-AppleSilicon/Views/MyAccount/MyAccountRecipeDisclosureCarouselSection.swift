//
//  MyAccountRecipeDisclosureCarouselSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct MyAccountRecipeDisclosureCarouselSection: View {
    let label: String
    let subtitle: String?
    let pagedRecipes: RecipeBasicsPaged?
    let onPresentRecipesTapped: () -> Void
    let onRecipeTapped: (Int64) -> Void
    
    init(
        _ label: String,
        _ subtitle: String?,
        _ pagedRecipes: RecipeBasicsPaged?,
        onPresentRecipesTapped: @escaping () -> Void,
        onRecipeTapped: @escaping (Int64) -> Void) {
        self.label = label
        self.subtitle = subtitle
        self.pagedRecipes = pagedRecipes
        self.onPresentRecipesTapped = onPresentRecipesTapped
        self.onRecipeTapped = onRecipeTapped
    }
    
    var body: some View {
        if let recipes = pagedRecipes?.content {
            MyAccountRecipeDisclosureCarousel(
                label: label,
                subtitle: subtitle,
                recipes: recipes,
                onDisclosureTapped: onPresentRecipesTapped,
                onRecipeTapped: onRecipeTapped)
        }
    }
}
