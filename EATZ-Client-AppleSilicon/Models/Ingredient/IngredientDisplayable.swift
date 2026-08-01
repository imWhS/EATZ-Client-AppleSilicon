//
//  IngredientDisplayable.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/11/26.
//

import Foundation

protocol IngredientDisplayable {
    var id: Int64 { get }
    var parentCoupled: Bool { get }
    var coupledParentName: String? { get } 
    var name: String { get }
    var hasChildren: Bool { get }
    var ownedByUser: Bool { get set }
    var likedByUser: Bool { get set }
}
