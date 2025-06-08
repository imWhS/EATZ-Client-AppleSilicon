//
//  UserBasic.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct UserBasic: Identifiable, Codable, Hashable {
    let id: Int
    let username: String
    let imageUrl: String?
}
