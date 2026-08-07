//
//  IngredientSearch.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation

struct SearchIngredientsRequest : Encodable {
    let keyword: String
    let page: Int
    let size: Int
}
