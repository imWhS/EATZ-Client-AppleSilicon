//
//  MyAccountRecipeDisclosureCarousel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct MyAccountRecipeDisclosureCarousel: View {
    let label: String
    let subtitle: String?
    let recipes: [RecipeBasic]
    let onDisclosureTapped: () -> Void
    let onRecipeTapped: (Int64) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                BasicMenuRow(label, false, .navigation, subtitle, onTapped: onDisclosureTapped)
                if !recipes.isEmpty {
                    RecipeCardCarousel(
                        recipes: recipes,
                        action: onRecipeTapped)
                    .padding(.bottom, 10)
                }
            }
            HorizontalDivider()
        }
    }
}
