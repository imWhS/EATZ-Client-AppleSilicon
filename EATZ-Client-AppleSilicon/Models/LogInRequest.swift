//
//  LogIn.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/18/26.
//

import Foundation

struct LogInRequest : Encodable {
    let email: String
    let password: String
}
