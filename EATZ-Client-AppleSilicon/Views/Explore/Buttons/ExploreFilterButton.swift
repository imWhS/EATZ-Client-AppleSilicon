//
//  ExploreFilterButton.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct ExploreFilterButton: View {
    let label: String
    let subtitle: String
    let action: () -> Void
    
    init(_ label: String, _ subtitle: String, action: @escaping () -> Void) {
        self.label = label
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.black)
                    ArrowCircledDown24()
                }
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray35)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(FilterButtonHighlightStyle())
        .padding(.top, 10)
    }
}
