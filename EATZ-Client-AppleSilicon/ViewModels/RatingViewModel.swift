//
//  RatingViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/25/25.
//

import Foundation
import SwiftUI

struct RatingViewAlertError: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String?
}

enum RecipeEssentialState: Equatable {
    case loading
    case loaded(RecipeEssential)
    case error(String)
}

enum RatingSummaryState: Equatable {
    case loading
    case loaded(RatingSummaryResponse)
    case error(String)
}

enum MyRatingState: Equatable {
    case loading
    case loaded(RatingItem)
    case loadedNothing
    case error(String)
}

enum RatingListState: Equatable {
    case idle
    case loading
    case loaded([RatingItem])
// TODO: case loaded([RatingListItem], hasNext: Bool, page: Int)
// TODO: case loadingNextPage([RatingListItem], page: Int)
    case error(String)
}

class RatingViewModel: ObservableObject {
    private lazy var authManager = AuthManager.shared
    
    let recipeId: Int64
    var currentUserId: Int64? = 0
    let isRecipeOwner: Bool = false
    
    private let userService = UserService()
    private let recipeService = RecipeService()
    
    /// 평가 등록 여부. RatingView가 최상위로 어떤 뷰를 화면에 보여줄지 결정합니다.
    @Published var shouldShowEmptyView: Bool = false
    
    /// 레시피 필수 정보.
    @Published var recipeEssential: RecipeEssential?
    @Published var recipeEssentialState: RecipeEssentialState = .loading
    
    /// 평가 요약 데이터 상태.
    @Published var ratingSummaryState: RatingSummaryState = .loading
    
    /// 내 평가 데이터 상태.
    @Published var myRatingState: MyRatingState = .loading
    
//    @Published var ratingSummary: RatingSummaryResponse?
    
    /// 평가 목록.
    @Published var ratings: [RatingItem] = []
//    @Published var ratingListState: RatingListState = .idle
    
    @Published var isErrorAlertPresented: Bool = false
    @Published var errorAlertMessage: String? = nil
    @Published var didSessionExpire: Bool = false
    
    @Published var alertError: RatingViewAlertError? = nil
    
    init(recipeId: Int64) {
        self.recipeId = recipeId
        self.currentUserId = authManager.currentUser?.id
    }
    
    func reloadAll() {
        fetchRecipeEssential()
        reloadAllRatings()
    }
    
    func reloadAllRatings() {
        print("DBG RATING - fetchAllRatings")
        fetchRatingSummary { [weak self] hasRatings in
            guard let self = self else { return }
            if hasRatings {
                self.fetchMyRating()
                self.fetchRatingList()
            } else {
                self.ratings = []
                self.myRatingState = .loadedNothing
            }
        }
    }
    
    func fetchRecipeEssential() {
        errorAlertMessage = nil
        recipeEssentialState = .loading
        
        recipeService.fetchRecipeEssential(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipeEssential):
                    self.recipeEssential = recipeEssential
                    self.recipeEssentialState = .loaded(recipeEssential)
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        print("[RatingViewModel] ERROR | \(afError.localizedDescription)")
                        self.recipeEssentialState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        print("[RatingViewModel] ERROR | \(errorResponse.message)")
                        self.recipeEssentialState = .error(errorResponse.message)
                    case .unknown:
                        print("[RatingViewModel] ERROR | 알 수 없는 이유로 레시피 주요 정보를 받아오지 못했어요.")
                        self.recipeEssentialState = .error("알 수 없는 이유로 레시피 주요 정보를 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                }
            }
        }
    }
    
    func fetchRatingSummary(completion: @escaping (Bool) -> Void) {
        print("DBG RATING - fetchRatingSummary")
        ratingSummaryState = .loading
        
        recipeService.fetchRatingSummary(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let summary):
                    self.ratingSummaryState = .loaded(summary)
                    let hasRatings = summary.average.count > 0
                    self.shouldShowEmptyView = !hasRatings
                    print("DBG RATING - shouldShowEmptyView: \(!hasRatings)")
                    completion(hasRatings)
                    
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        print("[RatingViewModel] ERROR | \(afError.localizedDescription)")
                        self.ratingSummaryState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        print("[RatingViewModel] ERROR | \(errorResponse.message)")
                        self.ratingSummaryState = .error(errorResponse.message)
                    case .unknown:
                        print("[RatingViewModel] ERROR | 알 수 없는 이유로 평가 요약을 받아오지 못했어요.")
                        self.ratingSummaryState = .error("알 수 없는 이유로 평가 요약을 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                    self.alertError = RatingViewAlertError(title: "평가 요약 가져오기 실패", message: networkError.localizedDescription)
                }
            }
        }
    }
    
    
    
    func fetchMyRating() {
        print("DBG RATING - fetchMyRating")
        myRatingState = .loading
        recipeService.fetchMyRating(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let response = response else {
                        self.myRatingState = .loadedNothing
                        return
                    }
                    
                    self.myRatingState = .loaded(response)
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        self.myRatingState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        self.myRatingState = .error(errorResponse.message)
                    case .unknown:
                        self.myRatingState = .error("알 수 없는 이유로 회원님의 평가를 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                    self.alertError = RatingViewAlertError(title: "내 평가 가져오기 실패", message: networkError.localizedDescription)
                }
            }
        }
    }
    
    func fetchRatingList(page: Int = 0, size: Int = 10) {
        print("DBG RATING - fetchRatingList")
        recipeService.fetchRatings(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
//                    self.ratingListState = .loaded(response.content)
                    self.ratings = response.content
                    self.shouldShowEmptyView = response.content.isEmpty
                    print("DBG RATING - shouldShowEmptyView: \(response.content.isEmpty)")
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        print("평가 목록 요청 오류: \(afError.localizedDescription)")
//                        self.ratingListState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        print("평가 목록 요청 오류: \(errorResponse.message)")
//                        self.ratingListState = .error(errorResponse.message)
                    case .unknown:
                        print("평가 목록 요청 오류: \("알 수 없는 이유로 평가 목록을 받아오지 못했어요. 다시 시도해보시겠어요?")")
//                        self.ratingListState = .error("알 수 없는 이유로 평가 목록을 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                    self.alertError = RatingViewAlertError(title: "평가 목록 가져오기 실패", message: networkError.localizedDescription)
                }
            }
        }
    }
    
    func deleteMyRating(id: Int64, onSuccess: @escaping () -> Void) {
        recipeService.deleteRating(id: id, recipeId: recipeId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    onSuccess()
                case .failure(let networkError):
                    print(networkError.localizedDescription)
                    self.alertError = RatingViewAlertError(title: "내 평가 삭제 실패", message: networkError.localizedDescription)
                }
            }
        }
    }
    
    func deleteRatingItem(id: Int64, onSuccess: @escaping () -> Void) {
        guard let index = ratings.firstIndex(where: { $0.id == id }) else {
            return
        }
        let deletedRating = ratings.remove(at: index)

        recipeService.deleteRating(id: id, recipeId: recipeId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    onSuccess()
                case .failure(let networkError):
                    let message: String
                    switch networkError {
                    case .afError(let error):
                        message = error.localizedDescription
                    case .serverError(let errorResponse):
                        message = errorResponse.message
                    case .unknown:
                        message = "알 수 없는 오류가 발생했어요. 다시 시도해보시겠어요?"
                    }
                    self.ratings.insert(deletedRating, at: index)
                    self.alertError = RatingViewAlertError(title: "평가 삭제 실패", message: message)
                }
            }
        }
    }
}
