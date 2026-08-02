//
//  SelectedKitchenwareItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/22/25.
//

import SwiftUI
import Kingfisher

struct SelectedKitchenwareItem: View {
    let name: String
    let imageUrl: String?
    var isFullWidth: Bool = false
    var onDeselect: (() -> Void)?
    
    var body: some View {
        if let onDeselect = self.onDeselect {
            Button(action: onDeselect) {
                contentView
            }
            .buttonStyle(.plain)
        } else {
            contentView
        }
    }
    
    @ViewBuilder
    private var kitchenwareImage: some View {
        if let imageUrl = imageUrl {
            KFImage(URL(imageUrlString: imageUrl))
                .placeholder {
                    Circle().fill(Color.white)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.075), lineWidth: 1)
                )
                .contentShape(Circle())
        } else {
            Circle()
                .fill(Color.white)
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.black.opacity(0.075), lineWidth: 1)
                )
                .contentShape(Circle())
        }
    }
    
    private var kitchenwareNameText: some View {
        Text(name)
            .font(.system(size: 17, weight: .medium))
    }
    
    private var contentView: some View {
        HStack(alignment: .center, spacing: 4) {
            HStack(alignment: .center, spacing: 8) {
                kitchenwareImage
                kitchenwareNameText
            }
            
            if isFullWidth {
                Spacer()
            }
            
            Image("remove-14")
        }
        .frame(height: 48)
    }
}
