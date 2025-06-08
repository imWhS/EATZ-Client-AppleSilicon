//
//  RatingView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: RatingViewModel
    
    var onHide: ((Int64) -> Void)?
    var onDelete: ((Int64) -> Void)?
    
    init(recipeId: Int64) {
        _viewModel = StateObject(wrappedValue: RatingViewModel(recipeId: recipeId))
    }
    
    var body: some View {
        NavigationStack {
                Group {
                    switch viewModel.summaryState {
                    case .loading:
                        ProgressView("평가 요약 불러오는 중...")
                    case .loaded(let summaryResponse):
                        ScrollView {
                            VStack(spacing: 20) {
                                RatingSummaryView(
                                    summary: RatingSummaryResponse(
                                        average: .init(
                                            count: summaryResponse.average.count,
                                            averageScore: summaryResponse.average.averageScore),
                                        distribution: summaryResponse.distribution
                                    )
                                )
                                
                                if let currentUser = authManager.currentUser {
                                    NewRatingActionView(username: currentUser.username, imageUrl: currentUser.imageUrl, onRegisterTapped: { print("평가 등록") })
                                }
                                
                                switch viewModel.listState {
                                case .idle, .loading:
                                    ProgressView("평가 목록 불러오는 중...")
                                        .navigationTitle("평가")
                                case .loaded(let ratings):
                                    RatingsListView(
                                        ratings: ratings,
                                        canManage: canManage,
                                        onHide: onHide,
                                        onDelete: onDelete
                                    )
                                    .navigationTitle("\(ratings.count)개의 평가")
                                case .error(let message):
                                    Text("평가 목록을 불러올 수 없어요: \(message)")
                                        .foregroundColor(.red)
                                        .navigationTitle("평가")
                                }
                            }
                            }
                    case .loadedNothing:
                        VStack(spacing: 8) {
                            Text("평가가 없어요.")
                                .font(.system(size: 18, weight: .bold))
                            Text("아직 아무도 이 레시피에 평가를 등록하지 않았어요.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.init("8F8F8F"))
                        }
                    case .error(let message):
                        VStack(spacing: 8) {
                            Text("평가 정보를 가져오지 못했어요.")
                                .font(.system(size: 18, weight: .bold))
                            Text("\(message)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.init("8F8F8F"))
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchRatingSummary()
                }
                .onChange(of: authManager.isLoggedIn) { newValue in
                    viewModel.refreshAllData()
                }
//                .authSheetPresenter()
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheetPresenter()
    }
    
    private func canManage(rating: RatingListItem) -> Bool {
        guard let myUserId = viewModel.myUserId else {
            return viewModel.isRecipeOwner
        }
        return viewModel.isRecipeOwner || rating.user.id == myUserId
    }
    
}

// MARK: - Ratings List

struct RatingsListView: View {
    let ratings: [RatingListItem]
    let canManage: (RatingListItem) -> Bool
    let onHide: ((Int64) -> Void)?
    let onDelete: ((Int64) -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("모든 평가")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 20)

            ForEach(ratings, id: \.id) { rating in
                RatingCardView(
                    rating: rating,
                    canManageRating: canManage(rating),
                    onHide: { onHide?(rating.id) },
                    onDelete: { onDelete?(rating.id) }
                )
            }
        }
    }
}

//#Preview {
//    let user = UserBasic(id: 1, username: "hee.xtory", imageUrl: "...")
//    let otherUser = UserBasic(id: 2, username: "cookstar", imageUrl: nil)
//    let ratings = [
//        RatingListItem(id: 1, user: user, score: 5, content: "최고!", createdAt: "2025-05-24 10:00:00"),
//        RatingListItem(id: 2, user: otherUser, score: 3, content: "보통이에요.", createdAt: "2025-05-24 11:00:00"),
//    ]
//
//    RatingView(
//        summary: RatingSummaryResponse(
//            average: .init(count: 1, averageScore: 4.5),
//            distribution: .init(
//                countScore5: 0,
//                countScore4: 0,
//                countScore3: 0,
//                countScore2: 0,
//                countScore1: 1
//            )
//        ),
//        ratings: ratings,
//        isRecipeOwner: true,
//        myUserId: 1,
//        onHide: { print("숨기기 \($0)") },
//        onDelete: { print("삭제하기 \($0)") }
//    )
//}
