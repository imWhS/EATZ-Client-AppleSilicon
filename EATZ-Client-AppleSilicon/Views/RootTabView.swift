//
//  RootTabView.swift
//  AuthInterceptorSample
//
//  Created by 손원희 on 5/15/25.
//

import SwiftUI

struct RootTabView: View {
    @State private var selection: MainTabItems = .explore
    @State private var previousSelection: MainTabItems = .explore
    
    @StateObject private var todayRouter = Router()
    @StateObject private var exploreRouter = Router()
    @StateObject private var plannerRouter = Router()
    @StateObject private var myAccountRouter = Router()
    
    var body: some View {
        TabView(selection: $selection) {
            CookableView()
                .tabItem { Label(MainTabItems.cookable.title, systemImage: MainTabItems.cookable.systemImage) }
                .tag(MainTabItems.cookable)
                .environmentObject(todayRouter)
            ExploreView()
                .tabItem { Label(MainTabItems.explore.title, systemImage: MainTabItems.explore.systemImage) }
                .tag(MainTabItems.explore)
                .environmentObject(exploreRouter)
            PlannerView()
                .tabItem { Label(MainTabItems.planner.title, systemImage: MainTabItems.planner.systemImage) }
                .tag(MainTabItems.planner)
                .environmentObject(plannerRouter)
            MyAccountView()
                .tabItem { Label(MainTabItems.myAccount.title, systemImage: MainTabItems.myAccount.systemImage) }
                .tag(MainTabItems.myAccount)
                .environmentObject(myAccountRouter)
        }
        .onChange(of: selection) { _, selection in self.selection = selection }
    }
}
