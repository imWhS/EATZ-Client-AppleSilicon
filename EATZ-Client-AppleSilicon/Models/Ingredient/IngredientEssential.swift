//
//  IngredientEssential.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct IngredientEssential: Hashable, Equatable, Codable, Identifiable {
    let id: Int64
    let parentCoupled: Bool
    let coupledParentName: String?
    let name: String
}
