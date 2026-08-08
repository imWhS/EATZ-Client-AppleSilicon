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
    var onDeselect: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            leadingView
            Remove14Button(action: onDeselect)
        }
        .frame(height: 48)
    }
    
    @ViewBuilder
    private var kitchenwareImage: some View {
        KFImage(URL(imageUrlString: imageUrl))
            .placeholder {
                Circle().fill(Color.white)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.075), lineWidth: 1)
                    .padding(.vertical, 0.5)
            )
            .contentShape(Circle())
            .padding(.vertical, 0.5)
    }
    
    private var kitchenwareNameText: some View {
        Text(name)
            .font(.system(size: 17, weight: .medium))
    }
    
    private var leadingView: some View {
        HStack(spacing: 4) {
            HStack(alignment: .center, spacing: 8) {
                kitchenwareImage
                kitchenwareNameText
            }
            
            if isFullWidth { Spacer() }
        }
    }
}
