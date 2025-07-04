//
//  RatingEditorViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/18/25.
//

import SwiftUI
import Alamofire

enum RatingEditorState: Equatable {
    case idle
    case submitting
    case submitted
    case error(String)
}

enum ExistingRatingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

class RatingEditorViewModel: ObservableObject {
    private lazy var authManager = AuthManager.shared
    
    @Published var recipeEssential: RecipeEssential?
    @Published var score: Int
    @Published var content: String
    @Published var currentUsername: String? = nil
    
    @Published var ratingEditorState: RatingEditorState = .idle
    @Published var existingRatingState: ExistingRatingState = .idle
    
    private let recipeId: Int64
    private let recipeService = RecipeService()
    var existingRating: RatingItem?
    
    
    init(recipeId: Int64, existing: RatingItem? = nil) {
        self.recipeId = recipeId
        self.score = existing?.score ?? 0
        self.content = existing?.content ?? ""
        
        if let currentUser = authManager.currentUser {
            self.currentUsername = currentUser.username
        }
    }
    
    func loadRecipeEssential() {
        recipeService.fetchRecipeEssential(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let recipeEssential):
                    self.recipeEssential = recipeEssential
                case .failure(let networkError):
                    print("[RatingEditorViewModel.loadRecipeEssential] 오류가 발생했어요: \(networkError.localizedDescription)")
                }
            }
        }
    }
    
    func setFormData(rating: RatingItem?) {
        existingRating = rating
        
        guard let existingRating = rating else {
            return
        }
        
        content = existingRating.content
        score = existingRating.score
    }
    
    func loadExistingRating() {
        existingRatingState = .loading
        recipeService.fetchMyRating(id: recipeId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let rating):
                    self.existingRatingState = .loaded
                    self.setFormData(rating: rating)
                case .failure(let networkError):
                    self.existingRatingState = .error(networkError.localizedDescription)
                }
            }
        }
    }
    
    func submit(onSuccess: @escaping () -> Void) {
        self.ratingEditorState = .submitting
        
        let completion: (Result<Empty, NetworkError>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.ratingEditorState = .submitted
                    onSuccess()
                    
                case .failure(let networkError):
                    // NetworkError에서 메시지를 뽑아 에러 상태에 담아주세요
                    self.ratingEditorState = .error(networkError.localizedDescription)
                }
            }
        }
        
        if let existingRating = existingRating {
            recipeService.updateRating(
                id: existingRating.id,
                recipeId: recipeId,
                score: score,
                content: content,
                completion: completion)
        } else {
            recipeService.submitRating(
                id: recipeId,
                score: score,
                content: content,
                completion: completion)
        }
    }
    
    func refreshAllData() {
        loadRecipeEssential()
        loadExistingRating()
    }
}
