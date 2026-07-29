//
//  CookableRecipeItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/5/25.
//

import SwiftUI
import Kingfisher

enum CookableRecipeItemAction {
    case save, addToPlanner, report
}

struct CookableRecipeItem: View {
    let recipe: CookableRecipe
    let onTappedRecipe: (Int64) -> Void
    let onAction: (CookableRecipe, CookableRecipeItemAction) -> Void
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let horizontalPadding: CGFloat = 20
    
    @State private var isPressed = false
    
    init(_ recipe: CookableRecipe,
         onTapItem: @escaping (Int64) -> Void,
         onAction: @escaping (CookableRecipe, CookableRecipeItemAction) -> Void,
         isPressed: Bool = false) {
        self.recipe = recipe
        self.onTappedRecipe = onTapItem
        self.onAction = onAction
        self.isPressed = isPressed
    }
    
    private var width: CGFloat {
        (screenWidth - (horizontalPadding * 2)) / 2
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { onTappedRecipe(recipe.id) }) {
                HStack(spacing: 0) {
                    RecipeItemThumbnail(
                        id: recipe.id,
                        isSaved: recipe.savedByUser,
                        imageUrlString: recipe.imageUrl,
                        width: width,
                        onSaveTapped: { id in onAction(recipe, .save) }
                    )
                    detailView
                }
                .clipped()
                .frame(height: width)
                .background(.white)
                .cornerRadius(20)
            }
            .buttonStyle(ListItemButtonStyle())
            
            footerView
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 10)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    @ViewBuilder
    private var footerView: some View {
        let missingKitchenwareCount = recipe.missingKitchenwareCount ?? 0
        let missingIngredientCount = recipe.missingIngredientCount ?? 0
        
        if missingKitchenwareCount > 0 || missingIngredientCount > 0 {
            HStack(spacing: 12) {
                if missingKitchenwareCount > 0 {
                    HStack(spacing: 4) {
                        Image("info-14")
                        Text("부족한 도구 수")
                            .foregroundStyle(Color.gray35)
                            .font(.system(size: 12, weight: .medium))
                        Text("\(missingKitchenwareCount)개")
                            .foregroundStyle(Color.black)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                
                if missingIngredientCount > 0 {
                    HStack(spacing: 4) {
                        Image("info-14")
                        Text("부족한 재료 수")
                            .foregroundStyle(Color.gray35)
                            .font(.system(size: 12, weight: .medium))
                        Text("\(missingIngredientCount)개")
                            .foregroundStyle(Color.black)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            EmptyView()
        }
    }
    
    private var detailView: some View {
        VStack(alignment: .leading) {
            Text(recipe.title)
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.black)
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    RecipeItemEssentialInfoView(
                        cookingTime: recipe.cookingTime,
                        prepTime: recipe.prepTime,
                        ratingAverageScore: recipe.ratingAverageScore,
                        ratingCount: recipe.ratingCount
                    )
                    Spacer()
                    actionMenu
                }
            }
        }
        .padding(14)
        .frame(width: width, height: width)
    }
    
    private var actionMenu: some View {
        Menu {
            Button {
                onAction(recipe, .addToPlanner)
            } label: {
                Label("플래너에 추가", systemImage: "plus.circle")
            }
            Button {
                onAction(recipe, .report)
            } label: {
                Label("신고", systemImage: "exclamationmark.bubble")
            }
        } label: {
            ArrowDownCircled20()
                .padding(4)
                .contentShape(Rectangle())
        }
    }
}
