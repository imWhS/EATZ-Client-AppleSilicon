//
//  RecipeView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/7/25.
//

import SwiftUI

struct RecipeListView: View {
    
    @StateObject private var viewModel = RecipeListViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("레시피 목록 불러오는 중...")
            } else {
                if viewModel.recipes.isEmpty {
                    Text("불러올 레시피 없음.")
                } else {
                    List(viewModel.recipes) { recipe in
                        VStack(alignment: .leading) {
                            Text("\(recipe.title)")
                            Text("\(recipe.createdAt)")
                        }
                    }
                }
            }
        }
        .onAppear {
            print("[RecipeListView] 레시피를 불러올게요")
            viewModel.loadRecipes()
        }
    }
}

#Preview {
    RecipeListView()
}
