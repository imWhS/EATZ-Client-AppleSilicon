//
//  RatingListResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/25/25.
//

import Foundation

struct RatingListResponse: Decodable {
    let content: [RatingListItem]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
