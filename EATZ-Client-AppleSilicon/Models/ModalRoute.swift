////
////  ModalRoute.swift
////  EATZ-Client-AppleSilicon
////
////  Created by 손원희 on 6/7/25.
////
//
//import SwiftUI
//
//enum ModalStyle { case sheet, fullScreenCover, alert }
//
//enum ModalRoute: Identifiable {
//    case authMain(promptMessage: AuthContext)
//    case ratingEditor(recipeId: Int64, onComplete: () -> Void)
//    
//    var id: String {
//        switch self {
//        case .authMain(let promptMessage):
//            return "authMain-\(promptMessage)"
//        case .ratingEditor(let recipeId, let onComplete):
//            return "ratingEditor-\(recipeId)"
//        }
//    }
//    
//    var style: ModalStyle {
//        switch self {
//        case .authMain:
//            return .fullScreenCover
//        case .ratingEditor:
//            return .fullScreenCover
//        }
//    }
//    
//    @ViewBuilder
//    var view: some View {
//        switch self {
//        case .authMain(let promptMessage):
//            AuthView(contextMessage: promptMessage)
//        case .ratingEditor(let recipeId, let onComplete):
//            RatingEditorView(recipeId: recipeId, onComplete: onComplete)
//        }
//    }
//}
