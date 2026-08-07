//
//  SelectableIngredientManager.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

import SwiftUI

protocol SelectableIngredientManager: ObservableObject {
    var selectedIngredients: [IngredientEssential] { get }
    func toggleSelection(for ingredient: Ingredient)
    func toggleSelection(for ingredient: IngredientEssential)
    func isSelected(_ id: Int64) -> Bool
    func isDisabled(_ ingredient: Ingredient) -> Bool
    func complete()
}

enum SelectableIngredientAlert: Identifiable {
    case userChanged(dismissAction: () -> Void)
    case sessionExpired(dismissAction: () -> Void)
    case error(message: String)
    
    var id: String {
        switch self {
        case .userChanged: return "userChanged"
        case .sessionExpired: return "sessionExpired"
        case .error(let message): return "error-\(message)"
        }
    }
    
    var alert: Alert {
        switch self {
        case .userChanged(let dismissAction):
            return Alert(
                title: Text("사용자 변경"),
                message: Text("기존과 다른 사용자로 로그인됐어요. 로그인 후 처음부터 다시 시도해주세요."),
                dismissButton: .default(Text("확인"), action: dismissAction)
            )
        case .sessionExpired(let dismissAction):
            return Alert(
                title: Text("세션 만료"),
                message: Text("로그아웃 상태로 전환됐어요. 로그인 후 처음부터 다시 시도해주세요."),
                dismissButton: .default(Text("확인"), action: dismissAction)
            )
        case .error(let message):
            return Alert(
                title: Text("오류"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}

enum SelectableIngredientViewState {
    case loading
    case loaded
    case unauthorized
    case error(String)
    case empty
}

enum SelectableIngredientSearchState {
    case searching
    case searched
    case error(String)
    case empty
}
