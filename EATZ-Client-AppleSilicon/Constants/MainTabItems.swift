//
//  MainTabItemsData.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/10/25.
//

import Foundation

enum MainTabItems: String, CaseIterable, Identifiable {
    case cookable
    case explore
    case planner
    case myAccount
    case hello
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .cookable: return "요리하기"
        case .explore: return "둘러보기"
        case .planner: return "플래너"
        case .myAccount: return "내 계정"
        case .hello: return "시작하기"
        }
    }
    
    var image: String {
        switch self {
        case .cookable: return "cookable-tab"
        case .explore: return "explore-tab"
        case .planner: return "planner-tab"
        case .myAccount: return "my-account-tab"
        case .hello: return "person.badge.plus"
        }
    }
}
