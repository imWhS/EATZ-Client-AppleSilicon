//
//  NewPasswordForReset.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation

struct ConfirmPasswordResetRequest : Encodable {
    let authorizedToken: String
    let newPassword: String
}
