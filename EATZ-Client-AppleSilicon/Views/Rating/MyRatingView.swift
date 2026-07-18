//
//  MyRatingView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/25.
//

import SwiftUI

struct MyRatingView: View {
    let currentUser: CurrentUser?
    let state: RatingMyStateOld
    let onRegisterTapped: () -> Void
    let onUpdateTapped: () -> Void
    let onDeleteTapped: (Rating) -> Void
    let onLogIn: () -> Void
    
    var body: some View {
        contentView(currentUser: currentUser, state: state)
    }
    
    @ViewBuilder
    func contentView(currentUser: CurrentUser?, state: RatingMyStateOld) -> some View {
        VStack(spacing: 20) {
            RatingSectionCommonHeaderView(title: "내 평가")
            if let currentUser = currentUser {
                switch state {
                case .initialLoading:
                    LoadMyRatingCard()
                case .loaded(let rating):
                    RatingCard(rating: rating) {
                        authorInteractionView(rating: rating)
                    }
                case .loadedNothing:
                    MyNewRatingCard(currentUser.username, currentUser.imageUrl, onRegisterTapped)
                case .error(let message):
                    Text("회원님의 평가를 불러올 수 없어요: \(message)")
                }
            } else {
                logInActionview
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state)
    }
    
    func authorInteractionView(rating: Rating) -> some View {
        HStack(spacing: 8) {
            Spacer()
            Button("삭제", action: { onDeleteTapped(rating) }).buttonStyle(SmallBorderlessButtonStyle())
            Button("수정", action: onUpdateTapped).buttonStyle(SmallBorderlessButtonStyle())
        }
        .padding(.horizontal, 12)
    }
    
    var logInActionview: some View {
        VStack {
            VStack(alignment: .center, spacing: 28) {
                VStack(spacing: 12) {
                    Image("handshake")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 48)
                        .foregroundStyle(Color.init(hex: "D1E7D7"))
                    VStack(spacing: 12) {
                        Text("레시피 평가")
                            .font(.system(size: 17, weight: .semibold))
                        Text("로그인 또는 가입 후, 이 레시피를 평가할 수 있어요.")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.init(hex: "93A197"))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                signWithEmailButton
            }
            .padding(.vertical, 28)
            .background(Color.init(hex: "EAF1EC"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .border(color: Color.init(hex: "EDEDED"), width: 1, radius: 20)
        }
        .padding(.horizontal, 20)
    }
    
    var authActionView: some View {
        VStack(spacing: 20) {
            Group {
                descriptionsSection
                signWithEmailButton
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.init(hex: "EAF1EC"))
        .cornerRadius(24)
    }
    
    private var descriptionsSection: some View {
        VStack(spacing: 12) {
            Image("handshake")
                .resizable()
                .scaledToFit()
                .frame(height: 48)
                .foregroundStyle(Color.init(hex: "D1E7D7"))
            VStack(spacing: 12) {
                Text("레시피 평가")
                    .font(.system(size: 17, weight: .semibold))
                Text("로그인 또는 가입 후, 이 레시피를 평가할 수 있어요.")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "93A197"))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var signWithEmailButton: some View {
        Button("이메일로 시작", action: onLogIn)
            .buttonStyle(SmallRoundedButtonStyle(type: .primary))
            .accentColor(Color.init(hex: "55C374"))
    }
}
