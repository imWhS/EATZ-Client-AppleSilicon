//
//  IngredientListResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import Foundation

struct IngredientDetailResponse: Decodable, Identifiable, Hashable {
    let id: Int64
    let name: String
    let parentCoupled: Bool
    let coupledParentName: String?
    let children: [Child]?
    
    struct Child: Codable, Identifiable, Hashable {
        let id: Int64
        let parentCoupled: Bool
        let coupledParentName: String?
        let name: String
        let hasChildren: Bool
        let ownedByUser: Bool
        let likedByUser: Bool
        
        func toListItem() -> IngredientEssential {
            return IngredientEssential(
                id: self.id,
                parentCoupled: self.parentCoupled,
                coupledParentName: self.coupledParentName,
                name: self.name)
        }
    }
    
    func toListItem() -> IngredientEssential {
        return IngredientEssential(
            id: self.id,
            parentCoupled: self.parentCoupled,
            coupledParentName: self.coupledParentName,
            name: self.name)
    }
}
