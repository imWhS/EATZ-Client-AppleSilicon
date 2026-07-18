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
    let onTapItem: (Int64) -> Void
    let onAction: (CookableRecipe, CookableRecipeItemAction) -> Void
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let horizontalPadding: CGFloat = 20
    
    @State private var isPressed = false
    
    init(_ recipe: CookableRecipe,
         onTapItem: @escaping (Int64) -> Void,
         onAction: @escaping (CookableRecipe, CookableRecipeItemAction) -> Void,
         isPressed: Bool = false) {
        self.recipe = recipe
        self.onTapItem = onTapItem
        self.onAction = onAction
        self.isPressed = isPressed
    }
    
    private var width: CGFloat {
        (screenWidth - (horizontalPadding * 2)) / 2
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { onTapItem(recipe.id) }) {
                HStack(spacing: 0) {
                    RecipeItemThumbnailView(
                        id: recipe.id,
                        saved: recipe.savedByUser,
                        imageUrl: recipe.imageUrl,
                        width: width,
                        onSave: { id in onAction(recipe, .save) }
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
                            .foregroundStyle(Color.init(hex: "A1A1A1"))
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
                            .foregroundStyle(Color.init(hex: "A1A1A1"))
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

private struct TodayCookableListItemThumbnailView: View {
    let imageUrl: String?
    let width: CGFloat
    let onSave: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            imageView
            Button(action: {
                onSave()
            }) {
                VStack {
                    Image("recipe-list-item-save")
                        .foregroundStyle(Color.white)
                        .padding(8)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 1)
                }
                .frame(width: 28, height: 28)
                .padding(4)
            }
            .buttonStyle(ScaleDownButtonStyle(cornerRadius: 12))
            .padding(8)
        }
    }
    
    @ViewBuilder
    private var imageView: some View {
        KFImage(URL(imageUrlString: imageUrl ?? ""))
            .resizable()
            .placeholder {
                ZStack {
                    Rectangle().foregroundStyle(.gray.opacity(0.2))
                    ProgressView()
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: width)
    }
}
