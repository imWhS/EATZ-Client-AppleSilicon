//
//  FindRecipesByAuthorRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/14/26.
//

import Foundation

struct FindRecipesByAuthorRequest : Encodable {
    let authorId: Int64
    let page: Int
    let size: Int
    
    init(_ authorId: Int64, _ page: Int = 0, _ size: Int = 10) {
        self.authorId = authorId
        self.page = page
        self.size = size
    }
}
