//
//  RatingView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI
import Kingfisher

enum EditorPresentType: Identifiable {
  case register
  case update(RatingItem)

  var id: Int {
    switch self {
    case .register: return -1
    case .update(let r): return Int(r.id)
    }
  }
}

struct RatingView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel: RatingViewModel
    
//    @State private var isPresentingEditRatingView = false
    @State private var editMode: EditorPresentType? = nil
    
    var onHide: ((Int64) -> Void)?
    var onDelete: ((Int64) -> Void)?
    
    init(
        recipeId: Int64
    ) {
        _viewModel = StateObject(wrappedValue: RatingViewModel(recipeId: recipeId))
    }
    
    var body: some View {
        Group {
            switch viewModel.ratingSummaryState {
            case .loading:
                ProgressView("평가 요약 불러오는 중...")
                    .toolbarBackground(.visible, for: .tabBar)
            case .loaded(let summaryResponse):
                ScrollView {
                    VStack(spacing: 0) {
                        if let recipeEssential = viewModel.recipeEssential {
                            HStack(alignment: .center, spacing: 12) {
                                KFImage(URL(string: recipeEssential.authorImageUrl))
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipeEssential.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .fontWeight(.bold)
                                    Text(recipeEssential.authorUsername)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color.init("8F8F8F"))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.init("F9F9F9"))
                            .cornerRadius(8)
                            .padding(20)
                            .clipped()
                        }

                        VStack(spacing: 40) {
                            RatingSummaryView(
                                summary: RatingSummaryResponse(
                                    average: .init(
                                        count: summaryResponse.average.count,
                                        averageScore: summaryResponse.average.averageScore),
                                    distribution: summaryResponse.distribution
                                )
                            )
                            
                            if authManager.isLoggedIn {
                                switch viewModel.myRatingState {
                                case .loading:
                                    ProgressView("불러오는 중...")
                                case .loaded(let rating):
                                    Text("hello")
                                    MyRatingItemView(
                                        rating: rating,
                                        onUpdateTapped: {
                                            if let recipeEssential = viewModel.recipeEssential {
                                                ModalManager.shared.sheet = .ratingEditor(recipeEssential: recipeEssential)
                                            }
                                        }, onDeleteTapped: {
                                            authManager.performAfterLogIn {
                                                print("평가 삭제")
                                            }
                                        })
                                case .loadedNothing:
                                    Text("hello")
                                    if let currentUser = authManager.currentUser {
                                        NewRatingActionView(username: currentUser.username, imageUrl: currentUser.imageUrl, onRegisterAction: {
                                            authManager.performAfterLogIn {
                                                if let recipeEssential = viewModel.recipeEssential {
                                                    ModalManager.shared.sheet = .ratingEditor(recipeEssential: recipeEssential)
                                                }
                                            }
                                        })
                                    }
                                case .error(let message):
                                    Text("회원님의 평가를 불러올 수 없어요: \(message)")
                                        .foregroundColor(.red)
                                }
                            } else {
                                LogInActionView()
                            }

                            switch viewModel.ratingListState {
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
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func canManage(rating: RatingItem) -> Bool {
        guard let myUserId = viewModel.myUserId else {
            return viewModel.isRecipeOwner
        }
        return viewModel.isRecipeOwner || rating.user.id == myUserId
    }
    
}

// MARK: - Ratings List

struct RatingsListView: View {
    let ratings: [RatingItem]
    let canManage: (RatingItem) -> Bool
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
