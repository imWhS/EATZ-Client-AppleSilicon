//
//  IngredientRow.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/11/26.
//

import SwiftUI

enum IngredientRowAppearance {
    case filled
    case outlined
    
    var background: Color {
        switch self {
        case .filled: .init(hex: "F8F8F8")
        case .outlined: .clear
        }
    }
    
    var borderColor: Color {
        switch self {
        case .filled: .clear
        case .outlined: .black.opacity(0.075)
        }
    }
}

struct IngredientRow<I: IngredientDisplayable, Icon: View, Trailing: View, Destination: View>: View {
    let ingredient: I
    let appearance: IngredientRowAppearance
    let isEnabled: Bool
    let isLinkable: Bool
    let linkDestination: Destination?
    @ViewBuilder let icon: Icon
    @ViewBuilder let trailing: Trailing
    
    init(_ ingredient: I,
         appearance: IngredientRowAppearance = .filled,
         isEnabled: Bool = true,
         isLinkable: Bool = false,
         linkDestination: Destination? = nil,
         @ViewBuilder icon: @escaping () -> Icon = { EmptyView() },
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.ingredient = ingredient
        self.appearance = appearance
        self.isEnabled = isEnabled
        self.isLinkable = isLinkable
        self.linkDestination = linkDestination
        self.icon = icon()
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            leading
            trailing
        }
        .frame(minHeight: 48)
        .background(appearance.background)
        .cornerRadius(14)
        .border(color: appearance.borderColor, width: 1, radius: 14)
    }
    
    @ViewBuilder
    private var leading: some View {
        HStack(spacing: 8) {
            if isLinkable && ingredient.hasChildren {
                ingredientNameTextLinkable.padding(.horizontal, 2)
            } else {
                ingredientNameText.padding(14)
            }
        }
    }
    
    private var ingredientNameText: some View {
        HStack {
            icon
            Text(ingredient.name)
                .font(.system(size: 17, weight: .medium))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var ingredientNameTextLinkable: some View {
        NavigationLink(
            destination: linkDestination) {
            HStack {
                ingredientNameText
                    .foregroundStyle(Color.accentColor)
                Image("arrow-right-14")
            }
            .contentShape(Rectangle())
            .padding(4)
        }
        .buttonStyle(SmallBorderlessButtonStyle())
    }
}

extension IngredientRow where Destination == EmptyView {
    init(_ ingredient: I,
         appearance: IngredientRowAppearance = .filled,
         isEnabled: Bool = true,
         isLinkable: Bool = false,
         @ViewBuilder icon: @escaping () -> Icon = { EmptyView() },
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.ingredient = ingredient
        self.appearance = appearance
        self.isEnabled = isEnabled
        self.isLinkable = isLinkable
        self.linkDestination = nil
        self.icon = icon()
        self.trailing = trailing()
    }
}
