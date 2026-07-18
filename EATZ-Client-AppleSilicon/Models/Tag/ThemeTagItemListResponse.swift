//
//  ThemeTagItemlistResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import Foundation


struct ThemeTagItemListResponse : Decodable {
    let content: [TagTheme]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasPrevious: Bool
    let hasNext: Bool
}
