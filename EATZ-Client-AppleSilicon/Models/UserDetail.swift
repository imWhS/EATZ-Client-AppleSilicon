//
//  UserDetail.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/13/25.
//

import Foundation

struct UserDetail: Codable {
    let id: Int64
    let username: String
    let email: String
    let role: UserRole
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
}

