//
//  NewRatingActionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct NewRatingActionView: View {
    let username: String
    let imageUrl: String?
    let onRegisterTapped: () -> Void
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        ProfileImageView(imageUrl: imageUrl, size: 32)
                        Text(username)
                            .font(.system(size: 12, weight: .bold))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        RatingStarsView(score: 0, starSize: 18)
                        .frame(height: 32)
                        .font(.system(size: 12))
                    }
                }
                VStack(spacing: 16) {
                    Button(action: {
                        onRegisterTapped()
                    }) {
                        Text("평가하기")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BigRoundedButtonStyle(type: .primary))
                    Text("아직 이 레시피를 평가하지 않았어요.\n레시피의 요리 경험을 공유해보세요.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.init("8F8F8F"))
                }
            }
            .padding(20)
            .border(color: Color.init("EDEDED"), width: 1, radius: 20)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NewRatingActionView(
        username: "hee.xtory",
        imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiZAwyv3ky9HdSIH32PzkhiCAPtsBGRZ49LA&s",
        onRegisterTapped: { print("평가 등록") })
}
