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
    let onEditTapped: () -> Void
    let onDeleteTapped: (RatingItem) -> Void
    
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
                        onUpdateTapped: onEditTapped,
                        onDeleteTapped: onDeleteTapped
                    )
                case .loadedNothing:
                    NewRatingActionView(username: currentUser.username, imageUrl: currentUser.imageUrl, onRegisterAction: onEditTapped)
                case .error(let message):
                    Text("회원님의 평가를 불러올 수 없어요: \(message)")
                        .foregroundColor(.red)
                }
            } else {
                LogInActionView()
            }
        }
        .padding(.vertical, 20)
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}
