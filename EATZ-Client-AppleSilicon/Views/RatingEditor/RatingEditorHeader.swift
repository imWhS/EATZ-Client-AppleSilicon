//
//  RatingEditorHeaderView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/19/25.
//

import SwiftUI
import Kingfisher

struct RatingEditorHeader: View {
    var recipeEssential: RecipeEssentialWithAuthor
    
    var body: some View {
        VStack(spacing: 20) {
            KFImage(URL(imageUrlString: recipeEssential.imageUrl))
                .placeholder {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 104, height: 104)
                .clipped()
                .cornerRadius(16)
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(recipeEssential.authorUsername)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.gray35)
                    Text(recipeEssential.title)
                        .font(.system(size: 22, weight: .semibold))
                        .multilineTextAlignment(.center)
                }
                Text("레시피의 요리 경험을 공유해보세요.\n점수와 후기는 언제든지 수정할 수 있어요.")
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.gray35)
            }
        }
        .padding(.horizontal, 20)
    }
}
