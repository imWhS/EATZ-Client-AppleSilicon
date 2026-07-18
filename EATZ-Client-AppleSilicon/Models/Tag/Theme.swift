//
//  Theme.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import Foundation

struct Theme: Codable, Identifiable {
    let id: Int64
    let name: String
    let description: String?
    let tags: [TagTheme]
}
