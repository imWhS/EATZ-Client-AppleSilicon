//
//  EatzDateEncodingStrategy.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation
import Alamofire

enum EatzDateEncodingStrategy {
    static let springBootLocalDateTimeJson = JSONEncoder.DateEncodingStrategy.custom { date, encoder in
        let formatter = EatzDateTimeFormatters.iso8601
        formatter.timeZone = .current
        let dateString = formatter.string(from: date)
        var container = encoder.singleValueContainer()
        try container.encode(dateString)
    }
}
