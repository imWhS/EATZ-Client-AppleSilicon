//
//  SystemClientVersionResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/6/26.
//

import Foundation

struct SystemClientVersionResponse: Decodable {
    let latestVersion: String
    let requiredVersion: String
    let message: String?
}
