//
//  CommentsPaged.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/8/25.
//

import Foundation

struct CommentsPaged : Decodable {
    let content: [Comment]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
