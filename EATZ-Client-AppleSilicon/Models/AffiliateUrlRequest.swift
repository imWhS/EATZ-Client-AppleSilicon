//
//  AffiliateUrlRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/20/26.
//

import Foundation

struct AffiliateUrlRequest: Encodable {
    let type: RequirementType?
    let id: Int64?
}
