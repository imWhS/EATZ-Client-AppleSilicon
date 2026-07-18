//
//  SelectedIngredientBar.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/22/25.
//

import SwiftUI

struct SelectedIngredientBar: View {
    var ingredients: [IngredientEssential] = []
    let onDeselectIngredient: (IngredientEssential) -> Void
    let placeholder: String
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            if !ingredients.isEmpty {
                mainContentView
            } else {
                emptyStateView
                    .padding(.vertical, 20)
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .background(Color.init(hex: "F9F9F9"))
    }
    
    private var mainContentView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ingredients) { ingredient in
                    SelectedIngredientItem(name: ingredient.name, onDeselect: {
                        onDeselectIngredient(ingredient)
                    })
                }
            }
            .padding(.horizontal, 20)
            .animation(.easeInOut(duration: 0.2), value: ingredients)
        }
        .padding(.vertical, 20)
        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
    }
    
    private var emptyStateView: some View {
        Text(placeholder)
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
            .foregroundStyle(.gray)
            .frame(height: 38)
    }
}
