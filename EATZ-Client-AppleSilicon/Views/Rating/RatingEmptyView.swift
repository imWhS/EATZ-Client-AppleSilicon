//
//  EmptyRatingsView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/26/25.
//

import SwiftUI

struct RatingEmptyView: View {
    var isLoggedIn: Bool
    var onRegisterTapped: (Bool) -> Void
    
    var body: some View {
        VStack {
            CommonEmptyStateView(
                title: "보여드릴 평가가 없어요.",
                "아직 아무도 이 레시피에 평가를 등록하지 않았어요.",
                "rating-star-40"
            )
            if isLoggedIn {
                userActionSection
            } else {
                guestActionSection
            }
        }
    }
    
    private var userActionSection: some View {
        Button(action: { onRegisterTapped(isLoggedIn) }) {
            Text("새 평가").frame(maxWidth: .infinity)
        }
        .buttonStyle(CapsuleLargeButtonStyle(appearance: .primary))
        .padding(20)
    }
    
    private var guestActionSection: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 12) {
                Image("handshake")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                    .foregroundStyle(Color.init(hex: "D1E7D7"))
                Button(action: { onRegisterTapped(isLoggedIn) }) {
                    Text("이메일로 시작").frame(maxWidth: .infinity)
                }
                .buttonStyle(CapsuleLargeButtonStyle(appearance: .authPrimary))
                Text("로그인 또는 가입하면 평가를 등록할 수 있어요.")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "93A197"))
            }
            .padding(20)
        }
    }
}
