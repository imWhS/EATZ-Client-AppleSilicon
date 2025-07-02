//
//  NewRatingActionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct LogInActionView: View {
    let onAction: () -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 28) {
                VStack(spacing: 8) {
                    Text("레시피 평가하기")
                        .font(.system(size: 20, weight: .bold))
                    Text("로그인 또는 가입 후, 이 레시피를 평가할 수 있어요.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.init("828282"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    onAction()
//                    ModalManager.shared.sheet = .authMain(promptMessage: .logIn)
                }) {
                    Text("이메일로 시작하기")
                }
                .buttonStyle(SmallRoundedButtonStyle(type: .primary))
            }
            .padding(.vertical, 32)
            .border(color: Color.init("EDEDED"), width: 1, radius: 20)
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
