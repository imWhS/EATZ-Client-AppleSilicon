//
//  RecipeEssentialView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/25.
//

import SwiftUI
import Kingfisher

struct RecipeEssentialView: View {
    enum Style {
        case gray
        case white
        
        var background: Color {
            switch self {
            case .gray: Color.backgroundPrimary
            case .white: Color.white
            }
        }
    }
    
    var recipeEssential: RecipeEssentialWithAuthor?
    
    var style: Style
    
    init(_ recipeEssential: RecipeEssentialWithAuthor? = nil, style: Style = .gray) {
        self.recipeEssential = recipeEssential
        self.style = style
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(style.background)
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
