//
//  RecipeDetailRequirementsKitchenwareSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/12/26.
//

import SwiftUI

struct RecipeDetailRequirementsKitchenwareSection: View {
    let isLoggedIn: Bool
    let kitchenwares: [RecipeKitchenware]
    let missingKitchenwareCount: Int?
    let onAction: (RecipeDetailRequirementsAction) -> Void
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let horizontalPadding: CGFloat = 20
    private let itemInnerHorizontalPadding: CGFloat = 4
    
    private var itemWidth: CGFloat {
        screenWidth - (horizontalPadding * 2) + (itemInnerHorizontalPadding * 2)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                VerticalLabeledValueView(
                    label: "총 도구 수",
                    value: "\(kitchenwares.count)개")
                if isLoggedIn,
                    let missingKitchenwareCount = missingKitchenwareCount,
                    0 < missingKitchenwareCount {
                    VerticalLabeledValueView(
                        label: "필요한 도구 수",
                        value: "\(missingKitchenwareCount)개",
                        style: .secondary
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            recipeRequirementsKitchenwareList
        }
    }
    
    private var recipeRequirementsKitchenwareList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(kitchenwares) { kitchenware in
                    RecipeDetailRequirementsKitchenwareItem(
                        kitchenware: kitchenware,
                        isLoggedIn: isLoggedIn,
                        onAction: onAction)
                    .frame(minWidth: itemWidth)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
    }
}
