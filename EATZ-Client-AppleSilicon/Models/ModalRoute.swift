//
//  ModalRoute.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/7/25.
//

import SwiftUI

enum ModalStyle { case sheet, fullScreenCover }

enum ModalRoute: Identifiable, Equatable {
    case authMain(promptMessage: AuthPresentMessageType)
    case rating(recipeId: Int64)
    
    var id: String {
        switch self {
        case .authMain(let promptMessage):
            return "authMain-\(promptMessage)"
        case .rating(let recipeId):
            return "rating-\(recipeId)"
        }
    }
    
    var style: ModalStyle {
        switch self {
        case .authMain:     return .fullScreenCover
        case .rating:       return .sheet
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .authMain(let promptMessage):
            AuthView(promptMessage: promptMessage)
        case .rating(let recipeId):
            RatingView(recipeId: recipeId)
        }
    }
}
