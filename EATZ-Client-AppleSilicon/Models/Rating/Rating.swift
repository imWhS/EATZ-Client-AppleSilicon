//
//  Rating.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct RatingItem: Identifiable, Codable, Hashable {
    let id: Int64
    let user: UserBasic
    let score: Int
    let content: String
    let createdAt: String
}
