//
//  KitchenwareEssential.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/20/25.
//

import Foundation

struct KitchenwareEssential: Codable, Equatable, Identifiable, Hashable {
    let id: Int64
    let name: String
    let imageUrl: String?
}
