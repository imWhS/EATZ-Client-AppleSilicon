//
//  VerifyValidationCode.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation

struct VerifyValidationCode : Encodable {
    let email: String
    let code: String
}
