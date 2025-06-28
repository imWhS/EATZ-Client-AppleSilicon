//
//  CurrentUser.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct CurrentUser: Identifiable, Codable, Hashable {
    let id: Int64
    let username: String
    let email: String
    let imageUrl: String?
}
