//
//  TagTheme.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import Foundation

struct TagTheme: Codable, Identifiable, Equatable {
    let id: Int64
    let name: String
    let keyword: String?
    let emoji: String?
    let description: String?
    let createdAt: Date
    let updatedAt: Date
}
