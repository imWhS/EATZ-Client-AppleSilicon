//
//  RecipeCardViewHeader.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/18/25.
//

import SwiftUI

struct RecipeCardViewHeader: View {
    var image: String
    var categories: [CategoryListItem]
    var title: String

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    ForEach(categories, id: \.self) { category in
                        Text("# \(category.name)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.init("BEBEB9"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.black)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
        }
    }
}

//#Preview {
//    RecipeCardViewHeader()
//}
