//
//  KitchenwareListItemResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/4/25.
//

import Foundation

struct KitchenwareListItemResponse:  Codable, Identifiable, Hashable {
    let id: Int64
    let name: String
    let imageUrl: String?
    let ownedByUser: Bool
    
    func toListItem() -> KitchenwareEssential {
        return KitchenwareEssential(id: self.id, name: self.name, imageUrl: self.imageUrl)
    }
}
