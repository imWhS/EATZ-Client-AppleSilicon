//
//  RecipeDetailCommonHeader.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/12/26.
//

import SwiftUI

struct RecipeDetailTitle: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.gray20)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
