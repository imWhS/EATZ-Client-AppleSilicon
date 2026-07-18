//
//  ChecklistIngredient.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/12/25.
//

struct ChecklistIngredient : Hashable, Equatable, Codable, Identifiable {
    let id: Int64
    let name: String
    var missing: Bool
    var likedByUser: Bool
}
