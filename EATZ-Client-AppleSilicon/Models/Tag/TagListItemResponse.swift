//
//  TagListItemResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/21/25.
//

import Foundation

struct TagListItemResponse : Decodable {
    let content: [Tag]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
