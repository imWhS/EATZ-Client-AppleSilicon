//
//  NewRatingActionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct LogInActionView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("레시피 평가하기")
                    .font(.system(size: 20, weight: .bold))
                Text("로그인 또는 가입 후, 이 레시피를 평가할 수 있어요.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.init("828282"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: {
                ModalManager.shared.sheet = .authMain(promptMessage: .logIn)
            }) {
                Text("이메일로 계속하기")
            }
            .buttonStyle(SmallRoundedButtonStyle(type: .primary))
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
