//
//  RootTabView.swift
//  AuthInterceptorSample
//
//  Created by 손원희 on 5/15/25.
//

import SwiftUI

struct RootTabView: View {
    @AppStorage("LastSelectedTab") private var selection: MainTabItems = .explore
    
    @State private var previousSelection: MainTabItems = .explore
    
    @StateObject private var todayRouter = Router()
    @StateObject private var exploreRouter = Router()
    @StateObject private var plannerRouter = Router()
    @StateObject private var myAccountRouter = Router()
    
    var body: some View {
        TabView(selection: $selection) {
            CookableView()
                .tabItem { Label(MainTabItems.cookable.title, image: MainTabItems.cookable.image) }
                .tag(MainTabItems.cookable)
                .environmentObject(todayRouter)
            ExploreView()
                .tabItem { Label(MainTabItems.explore.title, image: MainTabItems.explore.image) }
                .tag(MainTabItems.explore)
                .environmentObject(exploreRouter)
            PlannerView()
                .tabItem { Label(MainTabItems.planner.title, image: MainTabItems.planner.image) }
                .tag(MainTabItems.planner)
                .environmentObject(plannerRouter)
            MyAccountView()
                .tabItem { Label(MainTabItems.myAccount.title, image: MainTabItems.myAccount.image) }
                .tag(MainTabItems.myAccount)
                .environmentObject(myAccountRouter)
        }
    }
}
