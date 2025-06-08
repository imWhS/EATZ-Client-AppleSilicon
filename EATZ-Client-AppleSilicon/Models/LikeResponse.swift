//
//  LikeDto.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/20/25.
//

import Foundation

struct LikeResponse: Decodable {
    let id: Int64
    let entityId: Int64
    let type: EntityType
    let isLiked: Bool
    let createdAt: String
    let updatedAt: String
    let count: Int64
}
