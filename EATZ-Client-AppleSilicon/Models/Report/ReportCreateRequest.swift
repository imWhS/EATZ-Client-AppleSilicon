//
//  ReportCreateRequest.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/18/25.
//

import Foundation

struct ReportCreateRequest : Identifiable, Equatable, Encodable {
    let id = UUID()
    let resourceId: Int64
    let resourceType: ResourceType
    let categoryId: Int64
    let resourceContent: String?
    let description: String?
}
