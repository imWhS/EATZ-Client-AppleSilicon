//
//  IngredientRootResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import Foundation

struct IngredientBasic: Codable, Identifiable, Hashable {
    let id: Int64
    let name: String
    let hasChildren: Bool
    let ownedByUser: Bool
    let likedByUser: Bool
    
    func toListItem() -> IngredientEssential {
        return IngredientEssential(id: self.id, name: self.name)
    }
}
