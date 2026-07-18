//
//  RecipeEditorAddActionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/12/26.
//

import SwiftUI

struct RecipeEditorAddActionButton: View {
    var text: String
    var onAdd: () -> Void
    
    var body: some View {
        Button(action: {
            onAdd()
        }) {
            VStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.075), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        RecipeEditorAddActionButton(text: "재료 추가", onAdd: {print("추가")})
    }
    .padding(20)
    .background(Color.init(hex: "F9F9F9"))
}

