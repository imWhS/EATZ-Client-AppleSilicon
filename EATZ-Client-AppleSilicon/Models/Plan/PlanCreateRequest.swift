//
//  PlanCreateRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/5/25.
//

import Foundation

struct PlanCreateRequest: Codable {
    let recipeId: Int64
    let date: Date
    let priority: Int
}
