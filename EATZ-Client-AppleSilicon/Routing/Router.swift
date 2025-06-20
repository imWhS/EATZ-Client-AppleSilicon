//
//  Router.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/15/25.
//

import SwiftUI

@MainActor
class Router: ObservableObject {
    
    @Published var path = NavigationPath()
    
    func push(_ route: ViewRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
    
}
