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
    @ViewBuilder let icon: Icon
    @ViewBuilder let trailing: Trailing
    
    init(_ kitchenware: K,
         style: KitchenwareRowStyle = .filled,
         isEnabled: Bool = true,
         @ViewBuilder _ icon: @escaping () -> Icon = { EmptyView() },
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.kitchenware = kitchenware
        self.style = style
        self.isEnabled = isEnabled
        self.icon = icon()
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            leading
            trailing
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
        .padding(14)
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
        HStack {
            icon
            Text(kitchenware.name)
                .font(.system(size: 17, weight: .medium))
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
