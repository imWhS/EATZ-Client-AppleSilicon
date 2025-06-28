//
//  RatingRecipeEssentialView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/25.
//

import SwiftUI
import Kingfisher

struct RatingRecipeEssentialView: View {
    var state: RecipeEssentialState?
    
    var body: some View {
        Group {
            switch state {
            case .loading:
                HStack(alignment: .center, spacing: 12) {
                    KFImage(URL(string: ""))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("-")
                            .font(.system(size: 16, weight: .bold))
                            .fontWeight(.bold)
                        Text("-")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.init("8F8F8F"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init("F9F9F9"))
                .cornerRadius(8)
                .clipped()
                .padding(.horizontal, 20)
            case .loaded(let recipeEssential):
                HStack(alignment: .center, spacing: 12) {
                    KFImage(URL(string: recipeEssential.imageUrl))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipeEssential.title)
                            .font(.system(size: 16, weight: .bold))
                            .fontWeight(.bold)
                        Text(recipeEssential.authorUsername)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.init("8F8F8F"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init("F9F9F9"))
                .cornerRadius(8)
                .clipped()
                .padding(.horizontal, 20)
            case .error(let message):
                VStack(spacing: 8) {
                    Text("죄송합니다. 레시피 정보를 불러오지 못했어요.")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                }
            case .none:
                EmptyView()
            }
        }
        .padding(.vertical, 20)
    }
    
//    var body: some View {
//        HStack(alignment: .center, spacing: 12) {
//            KFImage(URL(string: recipeEssential.imageUrl))
//                .placeholder {
//                    ProgressView()
//                }
//                .resizable()
//                .scaledToFill()
//                .frame(width: 60, height: 60)
//                .clipped()
//            VStack(alignment: .leading, spacing: 4) {
//                Text(recipeEssential.title)
//                    .font(.system(size: 16, weight: .bold))
//                    .fontWeight(.bold)
//                Text(recipeEssential.authorUsername)
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(Color.init("8F8F8F"))
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.init("F9F9F9"))
//        .cornerRadius(8)
//        .padding(20)
//        .clipped()
//    }
}

//#Preview {
//    RatingRecipeEssentialView(
//        recipeEssential: RecipeEssential(id: 1, title: "주변 파출소 다 출동하게 만드는 간장 게장", imageUrl: "ttps://image.msscdn.net/thumbnails/display/images/usersnap/2024/03/17/ea480668361d431589ce6cf73afe9925.jpg?w=780", authorId: 1, authorUsername: "hee.xtory", authorImageUrl: "test"
//        )
//    )
//}
