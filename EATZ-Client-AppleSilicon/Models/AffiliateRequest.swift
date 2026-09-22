//
//  AffiliateRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/20/26.
//

import Foundation

struct AffiliateRequest: Encodable {
    let requirementType: RequirementType?
    let requirementId: Int64?
}
