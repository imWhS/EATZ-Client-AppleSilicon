//
//  ModalRoute.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/7/25.
//

import SwiftUI

enum ModalStyle { case sheet, fullScreenCover, alert }

enum ModalRoute: Identifiable, Equatable {
    case authMain(promptMessage: AuthPresentMessageType)
    case ratingEditor(recipeEssential: RecipeEssential)
//    case rating(recipeId: Int64)
    
    var id: String {
        switch self {
        case .authMain(let promptMessage):
            return "authMain-\(promptMessage)"
        case .ratingEditor(let recipeEssential):
            return "ratingEditor-\(recipeEssential.id)"
        }
    }
    
    var style: ModalStyle {
        switch self {
        case .authMain:
            return .fullScreenCover
        case .ratingEditor:
            return .sheet
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .authMain(let promptMessage):
            AuthView(promptMessage: promptMessage)
        case .ratingEditor(let recipeEssential):
            RatingEditorView(recipeEssential: recipeEssential)
        }
    }
}
