//
//  RecipeEssentialView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/25.
//

import SwiftUI
import Kingfisher

struct RecipeEssentialView: View {
    var recipeEssential: RecipeEssentialWithAuthor?
    
    init(_ recipeEssential: RecipeEssentialWithAuthor? = nil) {
        self.recipeEssential = recipeEssential
    }
    
    var body: some View {
        Group {
            if let recipeEssential = recipeEssential {
                HStack(alignment: .center, spacing: 12) {
                    KFImage(URL(imageUrlString: recipeEssential.imageUrl))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipeEssential.title)
                            .font(.system(size: 17, weight: .semibold))
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text(recipeEssential.authorUsername)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.init(hex: "8F8F8F"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(8)
                .clipped()
                .padding(.horizontal, 20)
            } else {
                Text("레시피 정보를 불러오지 못했어요.")
            }
        }
        .padding(.vertical, 10)
    }
}
