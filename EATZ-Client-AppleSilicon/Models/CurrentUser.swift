//
//  CurrentUser.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct CurrentUser: Identifiable, Codable, Hashable, Equatable {
    let id: Int64
    let username: String
    let email: String
    let imageUrl: String?
    let role: UserRole
    let publicId: String
    
    static func makeFake() -> CurrentUser {
        return CurrentUser(id: 1, username: "testAccount", email: "testAccount@eatz.io", imageUrl: "", role: .member, publicId: "44fdd3477dfdddsa")
    }
}
