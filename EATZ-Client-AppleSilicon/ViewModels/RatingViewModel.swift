//
//  RatingViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/25/25.
//

import Foundation

enum RatingSummaryState: Equatable {
    case loading
    case loaded(RatingSummaryResponse)
    case loadedNothing
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
    let myUserId: Int64? = 0
    let isRecipeOwner: Bool = false
    
    private let userService = UserService()
    private let recipeService = RecipeService()
    
    @Published var recipeEssential: RecipeEssential?
    @Published var ratingSummaryState: RatingSummaryState = .loading
    @Published var myRatingState: MyRatingState = .loading
    @Published var ratingListState: RatingListState = .idle
    @Published var isErrorAlertPresented: Bool = false
    @Published var errorAlertMessage: String? = nil
    @Published var didSessionExpire: Bool = false
    
    init(recipeId: Int64) {
        self.recipeId = recipeId
    }
    
    func fetchRecipeEssential() {
        errorAlertMessage = nil
        
        recipeService.fetchRecipeEssential(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipeEssential):
                    self.recipeEssential = recipeEssential
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        print("[RatingViewModel] ERROR | \(afError.localizedDescription)")
//                        self.recipeEssentialState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        print("[RatingViewModel] ERROR | \(errorResponse.message)")
//                        self.recipeEssentialState = .error(errorResponse.message)
                    case .unknown:
                        print("[RatingViewModel] ERROR | 알 수 없는 이유로 레시피 주요 정보를 받아오지 못했어요.")
//                        self.recipeEssentialState = .error("알 수 없는 이유로 레시피 주요 정보를 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                }
            }
        }
    }
    
    func fetchRatingSummary() {
        ratingSummaryState = .loading
        errorAlertMessage = nil
        
        recipeService.fetchRatingSummary(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let summary):
                    if summary.average.count == 0 {
                        self.ratingSummaryState = .loadedNothing
                        self.ratingListState = .loaded([])
                    } else {
                        self.ratingSummaryState = .loaded(summary)
                        
                        if (self.authManager.isLoggedIn) {
                            self.fetchMyRating()
                        }
                        
                        self.fetchRatingList()
                    }
                    
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
                }
            }
        }
    }
    
    func fetchMyRating() {
        myRatingState = .loading
        errorAlertMessage = nil
        recipeService.fetchMyRating(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let response = response else {
                        print("[DBG] my rating is nil")
                        self.myRatingState = .loadedNothing
                        return
                    }
                    
                    print("[DBG] my rating is NOT nil")
                    
                    self.myRatingState = .loaded(response)
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        print("[RatingViewModel] ERROR | \(afError.localizedDescription)")
                        self.myRatingState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        print("[RatingViewModel] ERROR | \(errorResponse.message)")
                        self.myRatingState = .error(errorResponse.message)
                    case .unknown:
                        print("[RatingViewModel] ERROR | 알 수 없는 이유로 사용자의 평가를 받아오지 못했어요.")
                        self.myRatingState = .error("알 수 없는 이유로 회원님의 평가를 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                }
            }
        }
    }
    
    func fetchRatingList(page: Int = 0, size: Int = 10) {
        ratingListState = .loading
        errorAlertMessage = nil
        recipeService.fetchRatings(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.ratingListState = .loaded(response.content)
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        self.ratingListState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        self.ratingListState = .error(errorResponse.message)
                    case .unknown:
                        self.ratingListState = .error("알 수 없는 이유로 평가 목록을 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                }
            }
        }
    }
    
    func refreshAllData() {
        fetchRatingSummary()
    }
    
}
