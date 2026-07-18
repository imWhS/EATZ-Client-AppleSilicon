//
//  AddRequirementButton.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/6/25.
//

import SwiftUI

struct ChecklistAddRequirementButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image("add-12")
                Text("추가")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Color.init(hex: "ECECEC"))
            .cornerRadius(6)
        }
    }
}
