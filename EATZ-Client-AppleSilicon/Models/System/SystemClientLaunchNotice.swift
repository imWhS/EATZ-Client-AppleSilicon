//
//  SystemClientLaunchNotice.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/6/26.
//

import Foundation

struct SystemClientLaunchNotice: Identifiable, Decodable {
    let id: Int64
    let title: String
    let markdownContent: String
    let force: Bool
}
