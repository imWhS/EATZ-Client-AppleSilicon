//
//  RecipeEssentialResponse.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 6/20/25.
//

import Foundation

struct RecipeEssential: Codable, Equatable {
    let id: Int64
    let title: String
    let imageUrl: String
    let authorId: Int64
    let authorUsername: String
    let authorImageUrl: String
}
