//
//  PlannerRecipePickerRecipeList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/20/26.
//

import SwiftUI

struct PlannerRecipePickerRecipeList: View {
    let headerTitle: String
    let pagedRecipes: Paged<RecipeBasic>
    let onRecipeTapped: (Int64) -> Void
    let loadMore: () -> Void
    
    private var recipes: [RecipeBasic] { pagedRecipes.items }
    
    var body: some View {
        ScrollView {
            RecipeBasicList(
                recipes,
                hasNextPage: pagedRecipes.hasNextPage,
                loadMore: loadMore,
                onRecipeTapped: { recipeId in onRecipeTapped(recipeId) },
                headerContent: listHeader
            )
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private func listHeader() -> some View {
        HStack {
            Text(headerTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray35)
                .padding(.leading, 20)
            Spacer()
        }
        .padding(.top, 4)
        .padding(.vertical, 16)
    }
}
