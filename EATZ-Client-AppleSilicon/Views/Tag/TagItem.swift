//
//  TagItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/16/25.
//

import SwiftUI

struct TagItem: View {
    let name: String
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.black)
                Spacer()
                Button("추가", action: onAddTapped)
                    .buttonStyle(RoundedButtonStyle(.secondary, .medium))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)

            HorizontalDivider()
        }
        .contentShape(Rectangle())
    }
}
