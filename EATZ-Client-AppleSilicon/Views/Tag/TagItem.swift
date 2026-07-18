//
//  TagItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/16/25.
//

import SwiftUI

struct TagItem: View {
    let name: String
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .foregroundStyle(.black)
                Spacer()
                Button("추가", action: onAdd).buttonStyle(SmallRoundedButtonStyle(type: .secondary))
            }
            .padding(.vertical, 12)
            
            Divider()
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }
}
