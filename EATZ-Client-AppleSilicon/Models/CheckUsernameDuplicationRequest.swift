//
//  CheckUsernameDuplicationRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/5/26.
//

import Foundation

struct CheckUsernameDuplicationRequest : Encodable {
    let username: String
    
    init(username: String) {
        self.username = username
    }
}
