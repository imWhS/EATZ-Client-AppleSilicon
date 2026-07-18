//
//  SearchRecipesForExplore.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/19/26.
//

import Foundation

struct SearchRecipesForExplore : Encodable {
    let searchCriteria: ExploreSearchCriteria
    let pageableRequest: PageableRequest
}
