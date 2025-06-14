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

enum RatingListState: Equatable {
    case idle
    case loading
    case loaded([RatingListItem])
// TODO: case loaded([RatingListItem], hasNext: Bool, page: Int)
// TODO: case loadingNextPage([RatingListItem], page: Int)
    case error(String)
}

class RatingViewModel: ObservableObject {
    private lazy var authManager = AuthManager.shared
    
    private let recipeId: Int64
    let myUserId: Int64? = 0
    let isRecipeOwner: Bool = false
    
    private let userService = UserService()
    private let recipeService = RecipeService()
    
    @Published var summaryState: RatingSummaryState = .loading
    @Published var listState: RatingListState = .idle
    @Published var isErrorAlertPresented: Bool = false
    @Published var errorAlertMessage: String? = nil
    @Published var didSessionExpire: Bool = false
    
    init(recipeId: Int64) {
        self.recipeId = recipeId
    }
    
    func fetchRatingSummary() {
        summaryState = .loading
        errorAlertMessage = nil
        
        recipeService.fetchRatingSummary(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let summary):
                    if summary.average.count == 0 {
                        self.summaryState = .loadedNothing
                        self.listState = .loaded([])
                    } else {
                        self.summaryState = .loaded(summary)
                        self.fetchRatingList()
                    }
                    
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        print("[RatingViewModel] ERROR | \(afError.localizedDescription)")
                        self.summaryState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        print("[RatingViewModel] ERROR | \(errorResponse.message)")
                        self.summaryState = .error(errorResponse.message)
                    case .unknown:
                        print("[RatingViewModel] ERROR | 알 수 없는 이유로 평가 요약을 받아오지 못했어요.")
                        self.summaryState = .error("알 수 없는 이유로 평가 요약을 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                }
            }
        }
    }
    
    func fetchRatingList(page: Int = 0, size: Int = 10) {
        listState = .loading
        errorAlertMessage = nil
        recipeService.fetchRatings(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.listState = .loaded(response.content)
                case .failure(let networkError):
                    switch networkError {
                    case .afError(let afError):
                        self.listState = .error(afError.localizedDescription)
                    case .serverError(let errorResponse):
                        self.listState = .error(errorResponse.message)
                    case .unknown:
                        self.listState = .error("알 수 없는 이유로 평가 목록을 받아오지 못했어요. 다시 시도해보시겠어요?")
                    }
                }
            }
        }
    }
    
    func refreshAllData() {
        fetchRatingSummary()
    }
    
}
