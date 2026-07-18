//
//  RecipeByUserItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/26/25.
//

import Foundation

struct RecipeByUserItem: Codable, Hashable {
    let id: Int64
    let title: String
    let description: String
    let url: String
    let imageUrl: String
    let createdAt: Date
    let updatedAt: Date
}
