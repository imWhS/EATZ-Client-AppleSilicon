//
//  RatingEditorViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/18/25.
//

import SwiftUI

enum RatingEditorState: Equatable {
    case idle
    case submitting
    case submitted
    case error(String)
}

class RatingEditorViewModel: ObservableObject {
    @Published var score: Int
    @Published var content: String
    @Published private(set) var state: RatingEditorState = .idle
    
    private let recipeId: Int64
    private let recipeService = RecipeService()
    private let existingRatingId: Int64?
    
    init(recipeId: Int64, existing: RatingItem? = nil) {
        self.recipeId = recipeId
        self.score = existing?.score ?? 0
        self.content = existing?.content ?? ""
        self.existingRatingId = existing?.id
    }
    
    func submit() {
    }
    
}
