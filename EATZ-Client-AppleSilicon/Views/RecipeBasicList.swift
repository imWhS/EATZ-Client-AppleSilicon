//
//  RecipeEssentialList.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/19/26.
//

import SwiftUI

struct RecipeBasicList<HeaderContent: View, MenuContent: View>: View {
    let recipes: [RecipeBasic]
    let hasNextPage: Bool
    let onLoadMore: () -> Void
    let onRecipeTapped: (Int64) -> Void
    
    @ViewBuilder let headerContent: (() -> HeaderContent)?
    @ViewBuilder let menuContent: ((RecipeBasic) -> MenuContent)?
    
    init(_ recipes: [RecipeBasic],
         hasNextPage: Bool,
         onLoadMore: @escaping () -> Void,
         onRecipeTapped: @escaping (Int64) -> Void,
         @ViewBuilder headerContent: @escaping () -> HeaderContent,
         @ViewBuilder menuContent: @escaping (RecipeBasic) -> MenuContent) {
        self.recipes = recipes
        self.hasNextPage = hasNextPage
        self.onLoadMore = onLoadMore
        self.onRecipeTapped = onRecipeTapped
        self.headerContent = headerContent
        self.menuContent = menuContent
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerContent?()
            LazyVStack(spacing: 0) {
                ForEach(recipes) { recipe in
                    RecipeBasicItem(
                        recipe: recipe,
                        onRecipeTapped: { recipe in onRecipeTapped(recipe.id) },
                        menuContent: menuContent)
                }
                
                if !recipes.isEmpty {
                    ListPageTailView(hasNextPage: hasNextPage, onAppearAction: onLoadMore).id(recipes.count)
                }
            }
        }
    }
}

extension RecipeBasicList where MenuContent == EmptyView {
    init(_ recipes: [RecipeBasic],
         hasNextPage: Bool,
         onLoadMore: @escaping () -> Void,
         onRecipeTapped: @escaping (Int64) -> Void,
         @ViewBuilder headerContent: @escaping () -> HeaderContent) {
        self.recipes = recipes
        self.hasNextPage = hasNextPage
        self.onLoadMore = onLoadMore
        self.onRecipeTapped = onRecipeTapped
        self.headerContent = headerContent
        self.menuContent = nil
    }
}

extension RecipeBasicList where HeaderContent == EmptyView {
    init(_ recipes: [RecipeBasic],
         hasNextPage: Bool,
         onLoadMore: @escaping () -> Void,
         onRecipeTapped: @escaping (Int64) -> Void,
         @ViewBuilder menuContent: @escaping (RecipeBasic) -> MenuContent) {
        self.recipes = recipes
        self.hasNextPage = hasNextPage
        self.onLoadMore = onLoadMore
        self.onRecipeTapped = onRecipeTapped
        self.headerContent = nil
        self.menuContent = menuContent
    }
}

extension RecipeBasicList where HeaderContent == EmptyView, MenuContent == EmptyView {
    init(_ recipes: [RecipeBasic],
         hasNextPage: Bool,
         onLoadMore: @escaping () -> Void,
         onRecipeTapped: @escaping (Int64) -> Void) {
        self.recipes = recipes
        self.hasNextPage = hasNextPage
        self.onLoadMore = onLoadMore
        self.onRecipeTapped = onRecipeTapped
        self.headerContent = nil
        self.menuContent = nil
    }
}
