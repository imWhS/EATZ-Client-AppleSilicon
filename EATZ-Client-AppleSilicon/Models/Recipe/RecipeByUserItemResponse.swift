//
//  RecipeByUserItemResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/26/25.
//

import Foundation

struct RecipeByUserItemResponse: Decodable {
    let content: [RecipeEssentialWithAuthor]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}


