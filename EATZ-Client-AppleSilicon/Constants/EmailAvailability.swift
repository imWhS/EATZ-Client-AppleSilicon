//
//  EmailAvailability.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/25/26.
//

import Foundation

enum EmailAvailability: String, Codable {
    case available = "AVAILABLE"
    case inUse = "IN_USE"
    case inCoolDown = "IN_COOLDOWN"
}
