//
//  RecipeDetailView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/12/25.
//

import SwiftUI

struct RecipeDetailView: View {
    var recipeId: Int64

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("recipe id: \(recipeId)")

            Spacer()
        }
        .padding()
        .navigationTitle("레시피 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
}
