//
//  RatingMySectionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/25.
//

import SwiftUI

struct RatingMySectionView: View {
    let currentUser: CurrentUser?
    let state: MyRatingState
    let onEdit: () -> Void
    let onDelete: (RatingItem) -> Void
    let onLogIn: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("내 평가")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 20)
            if let currentUser = currentUser {
                switch state {
                case .loading:
                    MyRatingItemEmptyView()
                case .loaded(let rating):
                    MyRatingItemView(
                        rating: rating,
                        onUpdateTapped: onEdit,
                        onDeleteTapped: onDelete
                    )
                case .loadedNothing:
                    NewRatingActionView(username: currentUser.username, imageUrl: currentUser.imageUrl, onRegisterAction: onEdit)
                case .error(let message):
                    Text("회원님의 평가를 불러올 수 없어요: \(message)")
                        .foregroundColor(.red)
                }
            } else {
                LogInActionView(onAction: onLogIn)
            }
        }
        .padding(.vertical, 20)
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}
