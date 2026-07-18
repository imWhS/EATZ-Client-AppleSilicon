//
//  Tag.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/24/25.
//

import Foundation

struct Tag: Codable, Identifiable, Hashable {
    let id: Int64
    let name : String
    let subtitle: String?
    let emoji: String?
    let description: String?
    let createdAt: Date
    let updatedAt: Date
}
