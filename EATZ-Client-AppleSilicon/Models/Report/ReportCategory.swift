//
//  ReportCategory.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/22/26.
//

import Foundation

struct ReportCategory: Identifiable, Hashable, Codable {
    let id: Int64
    let code: String
    let description: String
}
