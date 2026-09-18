//
//  KitchenwareRow.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/11/26.
//

import SwiftUI
import Kingfisher

struct KitchenwareRow<K: KitchenwareDisplayable, Icon: View, Trailing: View>: View {
    let kitchenware: K
    let style: KitchenwareRowStyle
    let isEnabled: Bool
    let isPurchasable: Bool
    let onPurchaseTapped: (() -> Void)?
    @ViewBuilder let icon: Icon
    @ViewBuilder let trailing: Trailing
    
    init(_ kitchenware: K,
         style: KitchenwareRowStyle = .filled,
         isEnabled: Bool = true,
         isPurchasable: Bool = false,
         onPurchaseTapped: (() -> Void)? = nil,
         @ViewBuilder _ icon: @escaping () -> Icon = { EmptyView() },
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.kitchenware = kitchenware
        self.style = style
        self.isEnabled = isEnabled
        self.isPurchasable = isPurchasable
        self.onPurchaseTapped = onPurchaseTapped
        self.icon = icon()
        self.trailing = trailing()
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                leading
                trailing
            }
        }
        .frame(minHeight: 48)
        .background(style.background)
        .cornerRadius(21)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(style.borderColor, lineWidth: 1)
        )
        .padding(.vertical, 0.5)
    }
    
    private var leading: some View {
        HStack(spacing: 12) {
            kitchenwareImage
            kitchenwareNameText
        }
        .padding(.leading, 14)
        .padding(.trailing, 8)
        .padding(.vertical, 14)
    }
    
    private var purchaseRow: some View {
        HStack(spacing: 8) {
            Image("shopping-16")
                .foregroundStyle(Color.gray35)
            Text("필요한 도구")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.gray35)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: onPurchaseTapped ?? {}) {
                HStack(spacing: 6) {
                    Text("쇼핑하기")
                    Image("external-link-14-light")
                }
            }
            .buttonStyle(SmallBorderlessButtonStyle())
        }
    }
    
    private var kitchenwareImage: some View {
        KFImage(URL(imageUrlString: kitchenware.imageUrl ?? ""))
            .placeholder {
                Circle().fill(Color.white)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .contentShape(Circle())
    }
    
    private var kitchenwareNameText: some View {
        VStack(spacing: 0) {
            HStack {
                icon
                Text(kitchenware.name)
                    .font(.system(size: 17, weight: .medium))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isPurchasable { purchaseRow }
        }
        .padding(.top, isPurchasable ? 6 : 0)
    }
}

enum KitchenwareRowStyle {
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
        case .outlined: .black.opacity(0.08)
        }
    }
}
