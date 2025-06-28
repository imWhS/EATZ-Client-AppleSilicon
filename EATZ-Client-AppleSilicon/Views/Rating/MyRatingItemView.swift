//
//  MyRatingItemView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct MyRatingItemView: View {
    let rating: RatingItem
    let onUpdateTapped: () -> Void
    let onDeleteTapped: (RatingItem) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        ProfileImageView(imageUrl: rating.user.imageUrl, size: 32)
                        Text(rating.user.username)
                            .font(.system(size: 12, weight: .bold))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        RatingStarsView(score: rating.score, starSize: 18)
                        .frame(height: 32)
                        HStack {
                            Text("\(rating.createdAt)")
                            Text("\(rating.score)점")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .font(.system(size: 12))
                    }
                }
                if (!rating.content.isEmpty) {
                    VStack(spacing: 16) {
                        HorizontalDividerView(horizontalPadding: 0)
                        Text(rating.content)
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(24)
            .background(Color.init("F9F9F9"))
            .cornerRadius(24)
            .padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                Spacer()
                Button(action: { onDeleteTapped(rating) }) {
                    Text("삭제하기")
                        .fontWeight(.bold)
                }
                .buttonStyle(SmallBorderlessButtonStyle())
                
                Button(action: {
                    
                    onUpdateTapped()
                }) {
                    Text("수정하기")
                        .fontWeight(.bold)
                }
                .buttonStyle(SmallBorderlessButtonStyle())
            }
            .padding(.horizontal, 8)
        }
    }
}

//#Preview {
//    NewRatingActionView(
//        username: "hee.xtory",
//        imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiZAwyv3ky9HdSIH32PzkhiCAPtsBGRZ49LA&s",
//        onRegisterTapped: { print("평가 등록") })
//}
