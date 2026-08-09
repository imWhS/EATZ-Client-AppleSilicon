//
//  ExploreRecipeGridList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/17/25.
//

import SwiftUI

struct ExploreRecipeGridList: View {
    let pagedRecipes: Paged<ExploreRecipe>
    
    let onTappedRecipe: (ExploreRecipe) -> Void
    let onTappedItemAction: (ExploreRecipe, ExploreRecipeItemAction) -> Void
    let loadMore: () -> Void
    
    var selectableSortOptions: [ExploreRecipesSort]
    @Binding var sort: ExploreRecipesSort
    
    private let rowSpacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 20
    
    private let columns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    private var cellWidth: CGFloat {
        ((UIScreen.main.bounds.width) - rowSpacing - (horizontalPadding * 2)) / 2
    }
    
    private var totalElementsLabel: String {
        if pagedRecipes.totalElements > 0 { return "\(pagedRecipes.totalElements)개의 레시피" }
        else { return "레시피" }
    }
    
    var body: some View {
        LazyVStack(spacing: 0) {
            header
            LazyVGrid(columns: columns, spacing: rowSpacing) {
                ForEach(pagedRecipes.items) { recipe in
                    ExploreRecipeItem(
                        recipe,
                        cardWidth: cellWidth,
                        onTappedRecipe: onTappedRecipe,
                        action: onTappedItemAction)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, rowSpacing)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: pagedRecipes.items)
            
            ListPageTailView(hasNextPage: pagedRecipes.hasNextPage, onAppear: loadMore)
        }
    }
    
    private var header: some View {
        HStack {
            Text(totalElementsLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray35)
                .padding(.leading, 20)
            Spacer()
            SortPicker(
                sort: $sort,
                selectableSorts: selectableSortOptions,
                isDisabled: pagedRecipes.isEmpty)
        }
        .padding(.top, 4)
        .padding(.bottom, 6)
    }
}
