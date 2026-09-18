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
            if isPurchasable { purchaseRow }
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
                ingredientNameText.padding(14)
            }
        }
    }
    
    private var purchaseRow: some View {
        VStack(spacing: 0) {
            HorizontalDivider(padding: 14)
            HStack(spacing: 8) {
                Image("shopping-16")
                    .foregroundStyle(Color.gray35)
                Text("필요한 재료를 온라인에서 준비해보세요.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray35)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                Button(action: onPurchaseTapped ?? {}) {
                    HStack(spacing: 6) {
                        Text("구입")
                        Image("external-link-14-light")
                    }
                }
                .buttonStyle(SmallBorderlessButtonStyle())
            }
            .padding(.leading, 14)
            .padding(.trailing, 8)
            .transition(.move(edge: .top))
        }
    }
    
    private var ingredientNameText: some View {
        HStack {
            icon
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
