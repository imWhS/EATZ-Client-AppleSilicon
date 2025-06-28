//
//  EmptyRatingsView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/26/25.
//

import SwiftUI

struct RatingEmptyView: View {
    var isLoggedIn: Bool
    var onRegister: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Image("rating-star")
                    .resizable()
                    .frame(width: 38, height: 38)
                    .foregroundStyle(Color.init("ECECEC"))
                VStack(spacing: 8) {
                    Text("평가가 없어요.")
                        .font(.system(size: 18, weight: .bold))
                    Text("아직 아무도 이 레시피에 평가를 등록하지 않았어요.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.init("8F8F8F"))
                }
            }
            Spacer()
            
            Button(action: {
                onRegister()
            }) {
                Text(isLoggedIn ? "평가하기" : "로그인 후 평가하기")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BigRoundedButtonStyle(type: .primary))
            .padding(20)
        }
        
    }
}

#Preview {
    RatingEmptyView(isLoggedIn: true) {
        print("새 평가")
    }
}
