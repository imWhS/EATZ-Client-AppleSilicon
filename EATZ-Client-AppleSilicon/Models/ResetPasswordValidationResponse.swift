//
//  ResetPasswordTokenValidationResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/17/25.
//

import Foundation

struct ResetPasswordTokenValidationResponse: Decodable {
    let authorizedToken: String
    let maskedEmail: String
}
