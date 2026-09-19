//
//  IngredientRow.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/11/26.
//

import SwiftUI

struct IngredientRow<I: IngredientDisplayable, Icon: View, Trailing: View, Destination: View>: View {
    let ingredient: I
    let style: IngredientRowStyle
    let isEnabled: Bool
    let isLinkable: Bool
    let isPurchasable: Bool
    let linkDestination: Destination?
    let onPurchaseTapped: (() -> Void)?
    @ViewBuilder let icon: Icon
    @ViewBuilder let trailing: Trailing
    
    init(_ ingredient: I,
         style: IngredientRowStyle = .filled,
         isEnabled: Bool = true,
         isLinkable: Bool = false,
         isPurchasable: Bool = false,
         linkDestination: Destination? = nil,
         onPurchaseTapped: (() -> Void)? = nil,
         @ViewBuilder icon: @escaping () -> Icon = { EmptyView() },
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.ingredient = ingredient
        self.style = style
        self.isEnabled = isEnabled
        self.isLinkable = isLinkable
        self.isPurchasable = isPurchasable
        self.linkDestination = linkDestination
        self.onPurchaseTapped = onPurchaseTapped
        self.icon = icon()
        self.trailing = trailing()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                leading
                trailing
            }
        }
        .frame(minHeight: 48)
        .background(style.background)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(style.borderColor, lineWidth: 1)
        )
        .padding(.vertical, 0.5)
        .animation(.easeInOut(duration: 0.3), value: ingredient.ownedByUser)
    }
    
    @ViewBuilder
    private var leading: some View {
        HStack(spacing: 8) {
            if isLinkable && ingredient.hasChildren {
                ingredientNameTextLinkable.padding(.horizontal, 2)
            } else {
                ingredientNameText
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, isPurchasable ? 8 : 14)
            }
        }
    }
    
    private var purchaseRow: some View {
        HStack(spacing: 8) {
            Button(action: onPurchaseTapped ?? {}) {
                HStack(spacing: 4) {
                    Image("shopping-14")
                    Text("재료 구입")
                }
            }
            .buttonStyle(SmallBorderlessButtonStyle())
            Spacer()
        }
    }
    
    private var ingredientNameText: some View {
        HStack(spacing: 2) {
            icon
                .padding(.bottom, isPurchasable ? 6 : 0)
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Group {
                        if ingredient.parentCoupled,
                           let coupledParentName = ingredient.coupledParentName,
                           coupledParentName.isEmpty == false {
                            Text(coupledParentName)
                                .foregroundStyle(Color.gray60)
                        }
                        Text(ingredient.name)
                            .foregroundStyle(Color.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 6)
                if isPurchasable { purchaseRow }
            }
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
         style: IngredientRowStyle = .filled,
         isEnabled: Bool = true,
         isLinkable: Bool = false,
         isPurchasable: Bool = true,
         onPurchaseTapped: (() -> Void)? = nil,
         @ViewBuilder icon: @escaping () -> Icon = { EmptyView() },
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.ingredient = ingredient
        self.style = style
        self.isEnabled = isEnabled
        self.isLinkable = isLinkable
        self.isPurchasable = isPurchasable
        self.linkDestination = nil
        self.onPurchaseTapped = onPurchaseTapped
        self.icon = icon()
        self.trailing = trailing()
    }
}

enum IngredientRowStyle {
    case filled
    case outlined
    
    var background: Color {
        switch self {
        case .filled: .gray2
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
