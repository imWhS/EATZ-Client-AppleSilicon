//
//  KitchenwareDisplayable.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/11/26.
//

import Foundation

protocol KitchenwareDisplayable {
    var id: Int64 { get }
    var name: String { get }
    var imageUrl: String? { get }
    var ownedByUser: Bool { get set }
}
