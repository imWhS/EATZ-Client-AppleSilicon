//
//  MainTabItemsData.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/10/25.
//

import Foundation

enum MainTabItemsData: String, CaseIterable, Identifiable {
    case explore
    case planner
    case myAccount
    case hello
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .explore: return "둘러보기"
        case .planner: return "플래너"
        case .myAccount: return "내 계정"
        case .hello: return "시작하기"
        }
    }
    
    var systemImage: String {
        switch self {
        case .explore: return "magnifyingglass"
        case .planner: return "calendar"
        case .myAccount: return "person.circle"
        case .hello: return "person.badge.plus"
        }
    }
}
