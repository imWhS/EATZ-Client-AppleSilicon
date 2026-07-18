//
//  LikeRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation

struct LikeRequest : Encodable {
    let entityId: Int64
    let type: LikableType
}
