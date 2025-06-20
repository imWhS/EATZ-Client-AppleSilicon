//
//  ViewRoute.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/14/25.
//

import Foundation

enum ViewRoute: Hashable {
    case recipe(id: Int64)   // 레시피 상세
    case rating(recipeId: Int64, recipeImageUrl: String, recipeTitle: String, recipeAuthorUsername: String)   // 평가 보기
    case profile(userId: Int64)    // 프로필
}
