//
//  RecipeView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/7/25.
//

import SwiftUI

enum RecipeListDestination: Hashable {
    case detail(recipeId: Int64)
}

struct RecipeListView: View {
    @StateObject private var viewModel = RecipeListViewModel()
    
    @State private var showBanner = true
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
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
            .navigationTitle("둘러보기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: RecipeListItem.self) { recipe in
                RecipeView(recipeId: recipe.id, navigationPath: $path)
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .searchView:
                    Text("레시피 검색")
                }
            }
        }
        .onAppear {
            viewModel.fetchRecipeList()
        }
    }
    
}

struct RecipeListItemsView: View {
    let recipes: [RecipeListItem]
    let onLikeTapped: (Int64) -> Void
    let onBookmarkTapped: (Int64) -> Void

    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(recipes, id: \.id) { recipe in
                NavigationLink(value: recipe) {
                    RecipeListItemView(
                        image: recipe.imageUrl ?? "",
                        categories: recipe.categories,
                        title: recipe.title,
                        onLikeTapped: { onLikeTapped(recipe.id) },
                        onBookmarkTapped: { onBookmarkTapped(recipe.id) }
                    )
                    .contentShape(Rectangle())
                }
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

#Preview {
    RecipeListView()
}
