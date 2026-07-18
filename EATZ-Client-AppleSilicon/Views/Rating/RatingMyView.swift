//
//  RatingMyView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/10/26.
//

import SwiftUI

struct RatingMyView: View {
    let username: String
    let userImageUrl: String?
    let state: RatingMyState
    let onRegisterTapped: () -> Void
    let onUpdateTapped: (Int64) -> Void
    let onDeleteTapped: (Rating) -> Void
    
    var body: some View {
        Group {
            switch state {
            case .initialLoading: LoadMyRatingCard()
            case .loaded(let rating):
                if let rating { RatingCard(rating: rating) { authorInteractionView(rating: rating) } }
                else { MyNewRatingCard(username, userImageUrl, onRegisterTapped) }
            case .error(let message): Text("회원님의 평가를 불러올 수 없어요: \(message)")
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state)
    }
    
    func authorInteractionView(rating: Rating) -> some View {
        HStack(spacing: 8) {
            Spacer()
            Button("삭제", action: { onDeleteTapped(rating) }).buttonStyle(SmallBorderlessButtonStyle())
            Button("수정", action: { onUpdateTapped(rating.id) }).buttonStyle(SmallBorderlessButtonStyle())
        }
        .padding(.horizontal, 12)
    }
    
}
