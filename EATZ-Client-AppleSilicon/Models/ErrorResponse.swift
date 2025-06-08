//
//  ErrorResponse.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/9/25.
//

import Foundation

struct ErrorResponse: Decodable {
    
    let errorCode: String
    let message: String
    let timestamp: String
    
}
