//
//  RecipeDetailSummarySection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/20/26.
//

import SwiftUI

struct RecipeDetailSummarySection: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                titleView
                tagsView
                infoItemsHorizontalView
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
        }
    }
    
    private var titleView: some View {
        Text(recipe.title)
            .font(.system(size: 30, weight: .bold))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var tagsView: some View {
        if 0 < recipe.tags.count {
            VStack(alignment: .leading, spacing: 4) {
                Text("태그")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "BCBCBC"))
                RecipeTagCloudView(tags: recipe.tags)
            }
        } else { EmptyView() }
    }
    
    private var infoItemsHorizontalView: some View {
        HStack(alignment: .center, spacing: 20) {
            VerticalLabeledValueView(
                label: "제공량",
                value: "\(recipe.servings)인, \(1)회")
            VerticalDivider(padding: 0)
            VerticalLabeledValueView(
                label: "소요 시간",
                value: EatzDurationFormatter.totalSeconds(from: recipe.cookingTime, recipe.prepTime) ?? "—")
            VerticalLabeledValueView(
                label: "준비 시간",
                value: EatzDurationFormatter.seconds(from: recipe.prepTime) ?? "—",
                style: .secondary)
        }
        .frame(height: 40)
    }
}


