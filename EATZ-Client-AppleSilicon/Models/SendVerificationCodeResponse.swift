//
//  SendVerificationCodeResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/15/25.
//

import Foundation

struct SendVerificationCodeResponse: Decodable, Hashable {
    let dailyIssuableLimits: Int
    let remainingIssuableAttempts: Int
}
