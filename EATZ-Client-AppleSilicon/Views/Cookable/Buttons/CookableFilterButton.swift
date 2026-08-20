//
//  CookableFilterButton.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct CookableFilterButton: View {
    let titleLabel: String
    let subtitleLabel: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 4) {
                VerticalDescriptionLabels(titleLabel, subtitleLabel)
                Spacer()
                ArrowCircledDown24()
            }
            .padding(20)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(FilterButtonHighlightStyle())
    }
}
