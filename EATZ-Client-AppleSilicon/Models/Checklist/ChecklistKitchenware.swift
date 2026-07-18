//
//  ChecklistKitchenware.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/6/25.
//

import Foundation

struct ChecklistKitchenware: Hashable, Equatable, Codable, Identifiable {
    let id: Int64
    let name: String
    let imageUrl: String?
    var missing: Bool
}
