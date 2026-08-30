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
    var appearance: RecipeEssentialAppearance
    
    init(_ recipeEssential: RecipeEssentialWithAuthor? = nil,
         _ appearance: RecipeEssentialAppearance = .gray) {
        self.recipeEssential = recipeEssential
        self.appearance = appearance
    }
    
    var body: some View {
        Group {
            if let recipeEssential = recipeEssential {
                HStack(alignment: .center, spacing: 0) {
                    KFImage(URL(imageUrlString: recipeEssential.imageUrl))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipeEssential.title)
                            .font(.system(size: 17, weight: .semibold))
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text(recipeEssential.authorUsername)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.gray35)
                    }
                    .padding(.horizontal, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(appearance.background)
                .cornerRadius(14)
                .clipped()
                .padding(.horizontal, 20)
            } else {
                Text("레시피 정보를 불러오지 못했어요.")
            }
        }
    }
}

enum RecipeEssentialAppearance {
    case gray
    case white
    
    var background: Color {
        switch self {
        case .gray: Color.backgroundPrimary
        case .white: Color.white
        }
    }
}
