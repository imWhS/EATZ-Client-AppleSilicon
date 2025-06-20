//
//  ExploreView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/7/25.
//

import SwiftUI

enum RecipeListDestination: Hashable {
    case detail(recipeId: Int64)
}

struct ExploreView: View {
    @StateObject private var viewModel = RecipeListViewModel()
    
    @State private var showBanner = true
//    @Binding var path: NavigationPath
//    @StateObject private var exploreRouter = Router()
    @EnvironmentObject private var router: Router
    
    var body: some View {
        NavigationStack(path: $router.path) {
            TabLayoutView(
                title: "레시피",
                buttons: [
                    HeaderIconButton(title: "카테고리") {
                        print("카테고리 버튼")
                    }
                ]) {
                    VStack {
                        RecipeSearchView()
                        
                        HStack {
                            Button("요리 가능") {
                                print("요리 가능")
                            }
                            .buttonStyle(FilterButtonStyle())
                        }
                        
                        if viewModel.isLoading {
                            ProgressView("레시피 목록 불러오는 중...")
                        } else {
                            RecipeListItemsView(
                                recipes: viewModel.recipes,
                                onCardTapped: { recipeId in
                                    print("Card tapped: \(recipeId)")
                                    router.push(.recipe(id: recipeId))
                                },
                                onLikeTapped: { recipeId in
                                    print("Liked: \(recipeId)")
                                },
                                onBookmarkTapped: { recipeId in
                                    print("Bookmarked: \(recipeId)")
                                }
                            )
                        }
                    }
                }
            .toolbar(.hidden, for: .navigationBar)
            .navigationTitle("둘러보기")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ViewRoute.self) { route in
                DestinationView(route: route)
            }
        }

        .onAppear {
            viewModel.fetchRecipeList()
        }
    }
    
}

struct RecipeListItemsView: View {
    let recipes: [RecipeListItem]
    let onCardTapped: (Int64) -> Void
    let onLikeTapped: (Int64) -> Void
    let onBookmarkTapped: (Int64) -> Void

    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(recipes, id: \.id) { recipe in
                RecipeListItemView(
                    image: recipe.imageUrl ?? "",
                    categories: recipe.categories,
                    title: recipe.title,
                    onCardTapped: { onCardTapped(recipe.id) },
                    onLikeTapped: { onLikeTapped(recipe.id) },
                    onBookmarkTapped: { onBookmarkTapped(recipe.id) }
                )
                .contentShape(Rectangle())
            }
        }
    }
}

struct RecipeSearchView: View {
    var body: some View {
        VStack {
            HStack {
                Image("recipe-list-search")
                VStack(alignment: .leading, spacing: 2) {
                    Group {
                        Text("제목, 내용")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("레시피 검색")
                            .font(.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundStyle(Color.init("6E6E6E"))
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(12)
            .background(Color.init("ECECEC"))
            .cornerRadius(10)
        }
        .padding(.horizontal, 20)
    }
}

//#Preview {
//    ExploreView()
//}
