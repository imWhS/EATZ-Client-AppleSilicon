//
//  UpdateRating.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation

struct UpdateRating : Encodable {
    let score: Int
    let content: String
}
