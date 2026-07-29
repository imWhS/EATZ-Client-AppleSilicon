//
//  Author.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct Author: Codable, Equatable, Hashable {
    let id: Int64
    let username: String
    let imageUrl: String?
    let bio: String?
    let recipeCount: Int?
    
    func toUserEssential() -> UserEssential {
        return UserEssential(id: id, username: username, imageUrl: imageUrl)
    }
}
