//
//  RatingEditorView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/17/25.
//

import SwiftUI

struct RatingEditorView: View {
    @EnvironmentObject var authManager: AuthManager
    
    let recipeEssential: RecipeEssential
//    let recipeId: Int64
//    let recipeImageUrl: String
//    let recipeTitle: String
//    let recipeAuthorUsername: String
    
    /**
     TODO: RatingEditorView 진입 시 리프레시 토큰 만료로 인해 재로그인해야 할 때, 다른 계정으로 로그인하는 경우 고려
     - RatingEditorView 파라미터는 레시피 ID, 레시피 이미지 URL, 레시피 제목, 레시피 작성자 사용자 이름만 받은 후, 서버에 GET localhost:8080/api/v0/recipes/{recipeId}/ratings/me 요청을 보낸 후 평가 정보 가져오도록 변경
     */
//    let existingRating: RatingItem?
    
//    @State private var score: Int
//    @State private var content: String
//    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("레시피 제목: \(recipeEssential.title)")
                Text("레시피 등록한 사용자: \(recipeEssential.authorUsername)")

            }
        }
        .task {
            authManager.fetchCurrentUser()
        }
        .sheetPresenter()
    }
}
