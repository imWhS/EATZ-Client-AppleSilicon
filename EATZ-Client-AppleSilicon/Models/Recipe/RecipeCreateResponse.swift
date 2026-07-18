//
//  RecipeCreateResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/30/25.
//

import Foundation

struct RecipeCreateResponse : Decodable {
    let id: Int64
    let createdAt: Date
}
