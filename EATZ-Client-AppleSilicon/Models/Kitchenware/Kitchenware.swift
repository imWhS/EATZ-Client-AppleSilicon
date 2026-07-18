//
//  Kitchenware.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct Kitchenware: Hashable, Equatable, Decodable, Identifiable, KitchenwareDisplayable {
    let id: Int64
    let name: String
    let imageUrl: String?
    var ownedByUser: Bool
    
    init(from item: KitchenwareListItemResponse) {
        self.id = item.id
        self.name = item.name
        self.imageUrl = item.imageUrl
        self.ownedByUser = item.ownedByUser
    }
    
    func toKitchenwareItem() -> KitchenwareEssential {
        return KitchenwareEssential(id: self.id, name: self.name, imageUrl: self.imageUrl)
    }
}
