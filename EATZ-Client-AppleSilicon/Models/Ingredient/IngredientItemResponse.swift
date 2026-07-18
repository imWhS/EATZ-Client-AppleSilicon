//
//  KitchenwareItemResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/2/25.
//

import Foundation

struct IngredientItemResponse: Decodable {
    let content: [IngredientEssential]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
