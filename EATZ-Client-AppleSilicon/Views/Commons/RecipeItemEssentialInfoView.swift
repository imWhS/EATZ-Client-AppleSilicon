//
//  RecipeItemEssentialInfoView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/25/25.
//

import SwiftUI

struct RecipeItemEssentialInfoView: View {
    let cookingTime: Int?
    let prepTime: Int?
    let ratingAverageScore: Double?
    let ratingCount: Int?
    
    var foregroundStyle: Color = .init(hex: "8B8B8B")
    var showRating: Bool = true
    var axis: Axis = .vertical
    
    var body: some View {
        layout
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(foregroundStyle)
    }
    
    @ViewBuilder
    private var layout: some View {
        if axis == .vertical {
            VStack(alignment: .leading, spacing: showRating ? 4 : 0) {
                timeView
                if showRating { ratingView }
            }
        } else {
            HStack(alignment: .center, spacing: showRating ? 4 : 0) {
                timeView
                if showRating { ratingView }
            }
        }
    }
    
    @ViewBuilder
    private var timeView: some View {
        EmptyView()
        if let recipeTime = EatzDurationFormatter.totalSeconds(from: cookingTime, prepTime) {
            HStack(alignment: .center, spacing: 2) {
                Image("recipe-list-item-time")
                Text(recipeTime)
            }
        } else {
            EmptyView()
        }
    }
    
    private var ratingView: some View {
        HStack(alignment: .center, spacing: 2) {
            Image("recipe-list-item-rating")
            HStack(spacing: 2) {
                Text(String(format: "%.1f", ratingAverageScore ?? 0.0))
                Text("(\(ratingCount ?? 0))")
                    .font(.system(size: 12, weight: .medium))
            }
        }
    }
}
