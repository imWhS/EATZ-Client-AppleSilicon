//
//  MyNewRatingCard.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct MyNewRatingCard: View {
    let username: String
    let imageUrl: String?
    let onRegisterAction: () -> Void
    
    init(_ username: String, _ imageUrl: String?, _ onRegisterAction: @escaping () -> Void) {
        self.username = username
        self.imageUrl = imageUrl
        self.onRegisterAction = onRegisterAction
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                RatingCardHeaderView(imageUrl: imageUrl, username: username)
                VStack(spacing: 16) {
                    Button(action: {
                        onRegisterAction()
                    }) {
                        Text("새 평가")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BigRoundedButtonStyle(type: .primary))
                    Text("아직 이 레시피를 평가하지 않았어요.\n레시피의 요리 경험을 공유해보세요.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.gray35)
                }
            }
            .padding(24)
            .border(color: Color.init(hex: "EDEDED"), width: 1, radius: 20)
        }
        .padding(.horizontal, 20)
    }
}

//#Preview {
//    NewRatingActionView(
//        username: "hee.xtory",
//        imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiZAwyv3ky9HdSIH32PzkhiCAPtsBGRZ49LA&s",
//        onRegisterTapped: { print("평가 등록") })
//}
