//
//  AffiliateResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/20/26.
//

import Foundation

struct AffiliateResponse: Decodable {
    let requirementType: RequirementType?
    let requirementId: Int64?
    let url: String
    let provider: String
}
