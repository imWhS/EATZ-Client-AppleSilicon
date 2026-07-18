//
//  EmailAvailabilityResponse.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/25/26.
//

import Foundation

struct EmailAvailabilityResponse : Decodable {
    let availability: EmailAvailability
    let message: String
}
