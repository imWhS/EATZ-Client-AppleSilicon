//
//  BlocklistResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/26.
//

import Foundation

struct BlocklistResponse : Decodable {
    let content: [UserEssential]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
