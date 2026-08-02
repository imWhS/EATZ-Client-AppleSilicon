//
//  IngredientSelectionItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/22/25.
//

import SwiftUI

struct SelectedIngredientItem: View {
    let parentCoupled: Bool
    let coupledParentName: String?
    let name: String
    var isFullWidth: Bool = false
    var onDeselect: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            leadingView
            Remove14Button(action: onDeselect)
        }
        .frame(height: 38)
        .padding(.horizontal, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.075), lineWidth: 1)
        )
        .padding(.vertical, 0.5)
    }
    
    private var leadingView: some View {
        HStack(spacing: 4) {
            Group {
                if parentCoupled,
                   let coupledParentName = coupledParentName,
                   coupledParentName.isEmpty == false {
                    Text(coupledParentName)
                        .foregroundStyle(Color.gray60)
                }
                Text(name)
            }
            .font(.system(size: 17, weight: .medium))
            
            if isFullWidth { Spacer() }
        }
    }
}
