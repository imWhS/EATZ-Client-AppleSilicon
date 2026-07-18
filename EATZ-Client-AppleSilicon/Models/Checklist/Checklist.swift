//
//  Checklist.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/9/25.
//

import Foundation

struct Checklist : Decodable {
    var uncookable: ChecklistCookability
    var cookable: ChecklistCookability
    let missingIngredientCount: Int
    let missingKitchenwareCount: Int
}

struct ChecklistCookability : Decodable {
    var plans: [ChecklistPlan]
    var requirements: ChecklistRequirements
}

struct ChecklistRequirements : Codable {
    var ingredients: [ChecklistIngredient]
    var kitchenwares: [ChecklistKitchenware]
}
