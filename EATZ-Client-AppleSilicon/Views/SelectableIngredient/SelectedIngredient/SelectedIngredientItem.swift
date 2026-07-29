//
//  IngredientSelectionItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/22/25.
//

import SwiftUI

struct SelectedIngredientItem: View {
    let name: String
    var isFullWidth: Bool = false
    var onDeselect: () -> Void
    
    var body: some View {
        Button(action: onDeselect) {
            HStack(alignment: .center, spacing: 4) {
                Text(name).font(.system(size: 17, weight: .medium))
                if isFullWidth { Spacer() }
                Image("remove-14")
            }
            .frame(height: 38)
            .padding(.horizontal, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.075), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        SelectedIngredientItem(name: "돼지고기 앞다리살", onDeselect: {print("제거")})
    }
    .padding(20)
    .background(Color.backgroundPrimary)
}
