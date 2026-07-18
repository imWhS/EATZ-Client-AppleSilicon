//
//  PageableRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation

struct PageableRequest : Encodable {
    let page: Int
    let size: Int
    
    init(_ page: Int = 0, _ size: Int = 10) {
        self.page = page
        self.size = size
    }
}
