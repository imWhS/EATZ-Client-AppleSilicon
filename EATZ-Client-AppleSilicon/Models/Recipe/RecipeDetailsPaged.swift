//
//  RecipeDetailsPaged.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/8/25.
//

import Foundation

struct RecipeDetailsPaged : Decodable {
    
    let content: [RecipeDetail]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
    
}
