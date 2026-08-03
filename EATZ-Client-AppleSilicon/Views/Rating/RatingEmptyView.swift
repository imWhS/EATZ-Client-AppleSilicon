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
                Image("rating-empty")
                VStack(spacing: 8) {
                    Text("보여드릴 평가가 없어요.")
                        .font(.system(size: 17, weight: .semibold))
                    Text("아직 아무도 이 레시피에 평가를 등록하지 않았어요.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.gray35)
                }
            }
            Spacer()
            
            Button(action: onRegister) {
                Text(isLoggedIn ? "새 평가" : "로그인 후 평가").frame(maxWidth: .infinity)
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
