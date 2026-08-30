//
//  CookableRecipeListToggle.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct CookableRecipeListToggle: View {
    @Binding var isCookableOnly: Bool
    var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Toggle(isOn: $isCookableOnly) {}
                .tint(.accent)
                .labelsHidden()
            Text("바로 요리 가능")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.black)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.25)
    }
}
