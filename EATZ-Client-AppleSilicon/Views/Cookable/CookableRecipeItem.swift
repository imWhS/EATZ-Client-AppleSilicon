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
    let isLoggedIn: Bool
    let onTappedRecipe: (Int64) -> Void
    let action: (CookableRecipe, CookableRecipeItemAction) -> Void
    
    @State private var isPressed = false
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let horizontalPadding: CGFloat = 20
    
    private var width: CGFloat {
        (screenWidth - (horizontalPadding * 2)) / 2
    }
    
    private var missingKitchenwareLabel: String {
        guard let missingIngredientCount = recipe.missingIngredientCount else { return "" }
        guard let count = recipe.missingKitchenwareCount else { return "" }
        if count == 0 { return "" }
        else {
            let suffix = missingIngredientCount == 0 ? "" : ","
            return "도구 \(count)개\(suffix)"
        }
    }

    private var missingIngredientLabel: String {
        guard let missingKitchenwareCount = recipe.missingKitchenwareCount else { return "" }
        guard let count = recipe.missingIngredientCount else { return "" }
        if count == 0 { return "" }
        else {
            let prefix = missingKitchenwareCount == 0 ? "" : " "
            return "\(prefix)재료 \(count)개"
        }
    }
    
    private var isCookable: Bool {
        return recipe.missingIngredientCount == 0 && recipe.missingKitchenwareCount == 0
    }
    
    init(_ recipe: CookableRecipe,
         _ isLoggedIn: Bool,
         onTappedRecipe: @escaping (Int64) -> Void,
         action: @escaping (CookableRecipe, CookableRecipeItemAction) -> Void,
         isPressed: Bool = false) {
        self.recipe = recipe
        self.isLoggedIn = isLoggedIn
        self.onTappedRecipe = onTappedRecipe
        self.action = action
        self.isPressed = isPressed
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            mainContentView
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 10)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var mainContentView: some View {
        Button(action: { onTappedRecipe(recipe.id) }) {
            HStack(spacing: 0) {
                RecipeItemThumbnail(
                    id: recipe.id,
                    isSaved: recipe.savedByUser,
                    imageUrlString: recipe.imageUrl,
                    width: width,
                    onSaveTapped: { id in action(recipe, .save) }
                )
                detailView
            }
            .clipped()
            .frame(height: width)
            .background(.white)
            .cornerRadius(20)
        }
        .buttonStyle(ListItemButtonStyle())
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
    
    @ViewBuilder
    private var cookableStatusView: some View {
        HStack(spacing: 4) {
            Image(isCookable ? "requirement-available-16" : "requirement-unavailable-16")
                .resizable()
                .frame(width: 16, height: 16)
            
            Group {
                if isCookable {
                    Text("바로 요리 가능")
                } else {
                    Text("\(missingKitchenwareLabel)\(missingIngredientLabel) 부족")
                }
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isCookable ? Color.requirementGreen : Color.requirementYellow)
        }
        
    }
    
    private var detailView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isLoggedIn { cookableStatusView }
            Text(recipe.title)
                .font(.system(size: 17, weight: .semibold))
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.black)
                .frame(maxHeight: .infinity, alignment: .top)
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
                action(recipe, .addToPlanner)
            } label: {
                Label("플래너에 추가", systemImage: "plus")
            }
            Button {
                action(recipe, .report)
            } label: {
                Label("신고", systemImage: "exclamationmark.bubble")
            }
        } label: {
            ArrowCircledDown24()
                .padding(4)
                .contentShape(Rectangle())
        }
    }
}
