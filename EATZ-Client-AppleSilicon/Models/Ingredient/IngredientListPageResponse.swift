//
//  IngredientRootListPageResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/3/25.
//

import Foundation

struct IngredientListPageResponse : Decodable {
    let content: [IngredientBasic]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
